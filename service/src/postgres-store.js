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
