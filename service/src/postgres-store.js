import { randomBytes } from "node:crypto";

const FEEDS = new Set(["new", "popular", "trending", "curated"]);

export class PostgresStore {
  constructor(pool) {
    this.pool = pool;
  }

  async init() {
    await this.pool.query("SELECT 1");
  }

  async publish({ creatorId, clientLevelId, level, now = Date.now() }) {
    const client = await this.pool.connect();
    try {
      await client.query("BEGIN");
      let row = (await client.query(
        `SELECT public_id, latest_revision
           FROM community_levels
          WHERE creator_id = $1 AND client_level_id = $2
          FOR UPDATE`,
        [creatorId, clientLevelId],
      )).rows[0];

      if (!row) {
        const publicId = makePublicId();
        const inserted = await client.query(
          `INSERT INTO community_levels (public_id, creator_id, client_level_id, latest_revision)
           VALUES ($1, $2, $3, 0)
           ON CONFLICT (creator_id, client_level_id) DO NOTHING
           RETURNING public_id, latest_revision`,
          [publicId, creatorId, clientLevelId],
        );
        row = inserted.rows[0];
        if (!row) {
          row = (await client.query(
            `SELECT public_id, latest_revision
               FROM community_levels
              WHERE creator_id = $1 AND client_level_id = $2
              FOR UPDATE`,
            [creatorId, clientLevelId],
          )).rows[0];
        }
      }

      const revision = Number(row.latest_revision) + 1;
      const publishedAt = Math.floor(now / 1000);
      await client.query(
        `INSERT INTO community_level_revisions (public_id, revision, published_at, level)
         VALUES ($1, $2, $3, $4::jsonb)`,
        [row.public_id, revision, publishedAt, JSON.stringify(level)],
      );
      await client.query(
        `UPDATE community_levels SET latest_revision = $2 WHERE public_id = $1`,
        [row.public_id, revision],
      );
      await client.query(
        `INSERT INTO community_level_stats (public_id) VALUES ($1)
         ON CONFLICT (public_id) DO NOTHING`,
        [row.public_id],
      );
      await client.query("COMMIT");
      return this.getRevision(row.public_id, revision);
    } catch (error) {
      try { await client.query("ROLLBACK"); } catch {}
      throw error;
    } finally {
      client.release();
    }
  }

  async getRevision(publicId, revision) {
    const result = await this.pool.query(
      `SELECT l.public_id, l.creator_id, r.revision, r.published_at,
              r.level, s.plays, s.likes
         FROM community_levels l
         JOIN community_level_revisions r ON r.public_id = l.public_id
         JOIN community_level_stats s ON s.public_id = l.public_id
        WHERE l.public_id = $1 AND r.revision = $2 AND s.takedown = FALSE`,
      [publicId, revision],
    );
    return result.rows[0] ? mapEntry(result.rows[0]) : null;
  }

  async listFeed(feed) {
    if (!FEEDS.has(feed)) throw new Error("invalid_feed");

    const where = feed === "curated" ? "AND s.curated = TRUE" : "";
    const order = feed === "popular"
      ? "s.likes DESC, s.plays DESC, r.published_at DESC, l.public_id DESC"
      : feed === "trending"
        ? "((s.likes * 3 + s.plays + 1)::double precision / POWER(GREATEST(1, (EXTRACT(EPOCH FROM NOW()) - r.published_at) / 3600.0), 0.45)) DESC, r.published_at DESC, l.public_id DESC"
        : "r.published_at DESC, l.public_id DESC";

    const result = await this.pool.query(
      `SELECT l.public_id, l.creator_id, r.revision, r.published_at,
              r.level, s.plays, s.likes
         FROM community_levels l
         JOIN community_level_revisions r
           ON r.public_id = l.public_id AND r.revision = l.latest_revision
         JOIN community_level_stats s ON s.public_id = l.public_id
        WHERE s.takedown = FALSE ${where}
        ORDER BY ${order}`,
    );
    return result.rows.map(mapEntry);
  }

  async recordPlay(publicId) {
    const result = await this.pool.query(
      "UPDATE community_level_stats SET plays = plays + 1 " +
      "WHERE public_id = $1 AND takedown = FALSE RETURNING plays, likes",
      [publicId],
    );
    if (!result.rows[0]) return null;
    return {
      plays: Number(result.rows[0].plays),
      likes: Number(result.rows[0].likes),
    };
  }

  async setLike({ publicId, userId, liked, now = Date.now() }) {
    const client = await this.pool.connect();
    try {
      await client.query("BEGIN");
      const locked = await client.query(
        "SELECT plays, likes, takedown FROM community_level_stats WHERE public_id = $1 FOR UPDATE",
        [publicId],
      );
      if (!locked.rows[0] || locked.rows[0].takedown) {
        await client.query("ROLLBACK");
        return null;
      }

      let changed = false;
      if (liked) {
        const inserted = await client.query(
          "INSERT INTO community_level_likes (public_id, user_id, created_at) VALUES ($1, $2, $3) " +
          "ON CONFLICT (public_id, user_id) DO NOTHING RETURNING public_id",
          [publicId, userId, Math.floor(now / 1000)],
        );
        changed = inserted.rowCount === 1;
        if (changed) {
          await client.query(
            "UPDATE community_level_stats SET likes = likes + 1 WHERE public_id = $1",
            [publicId],
          );
        }
      } else {
        const removed = await client.query(
          "DELETE FROM community_level_likes WHERE public_id = $1 AND user_id = $2 RETURNING public_id",
          [publicId, userId],
        );
        changed = removed.rowCount === 1;
        if (changed) {
          await client.query(
            "UPDATE community_level_stats SET likes = GREATEST(0, likes - 1) WHERE public_id = $1",
            [publicId],
          );
        }
      }

      const stats = (await client.query(
        "SELECT plays, likes FROM community_level_stats WHERE public_id = $1",
        [publicId],
      )).rows[0];
      await client.query("COMMIT");
      return {
        plays: Number(stats.plays),
        likes: Number(stats.likes),
        liked: Boolean(liked),
      };
    } catch (error) {
      try { await client.query("ROLLBACK"); } catch {}
      throw error;
    } finally {
      client.release();
    }
  }

  async report({ publicId, userId, reason, now = Date.now() }) {
    const result = await this.pool.query(
      "INSERT INTO community_level_reports (public_id, reporter_id, reason, reported_at) " +
      "SELECT $1, $2, $3, $4 WHERE EXISTS (" +
      "SELECT 1 FROM community_level_stats WHERE public_id = $1 AND takedown = FALSE" +
      ") ON CONFLICT (public_id, reporter_id) DO UPDATE SET reason = EXCLUDED.reason, reported_at = EXCLUDED.reported_at " +
      "RETURNING public_id",
      [publicId, userId, reason, Math.floor(now / 1000)],
    );
    return result.rows[0] ? { accepted: true } : null;
  }

  async moderate({ publicId, curated = null, takedown = null }) {
    const result = await this.pool.query(
      "UPDATE community_level_stats SET curated = COALESCE($2, curated), takedown = COALESCE($3, takedown) " +
      "WHERE public_id = $1 RETURNING curated, takedown",
      [publicId, curated, takedown],
    );
    if (!result.rows[0]) return null;

    const reportCount = await this.pool.query(
      "SELECT COUNT(*)::bigint AS reports FROM community_level_reports WHERE public_id = $1",
      [publicId],
    );
    return {
      public_id: publicId,
      moderation: {
        curated: Boolean(result.rows[0].curated),
        takedown: Boolean(result.rows[0].takedown),
        reports: Number(reportCount.rows[0].reports),
      },
    };
  }
}

function mapEntry(row) {
  return {
    public_id: row.public_id,
    revision: Number(row.revision),
    creator_id: row.creator_id,
    published_at: Number(row.published_at),
    stats: { plays: Number(row.plays), likes: Number(row.likes) },
    level: structuredClone(row.level),
  };
}

function makePublicId() {
  return `ERROW-${randomBytes(6).toString("hex").toUpperCase()}`;
}
