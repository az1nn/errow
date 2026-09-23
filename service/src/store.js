import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { dirname } from "node:path";
import { randomBytes } from "node:crypto";

const EMPTY_STATE = () => ({ version: 1, levels: {}, client_index: {}, stats: {} });
const FEEDS = new Set(["new", "popular", "trending", "curated"]);

export class JsonFileStore {
  constructor(filePath) {
    this.filePath = filePath;
    this.state = EMPTY_STATE();
    this.queue = Promise.resolve();
  }

  async init() {
    try {
      const parsed = JSON.parse(await readFile(this.filePath, "utf8"));
      this.state = normalizeState(parsed);
    } catch (error) {
      if (error?.code !== "ENOENT") throw error;
      await mkdir(dirname(this.filePath), { recursive: true });
      await this.#persist();
    }
  }

  async publish({ creatorId, clientLevelId, level, now = Date.now() }) {
    return this.#serialized(async () => {
      const clientKey = `${creatorId}\u0000${clientLevelId}`;
      const existingId = this.state.client_index[clientKey];
      const publicId = existingId ?? makePublicId();
      const record = this.state.levels[publicId] ?? {
        creator_id: creatorId,
        latest_revision: 0,
        revisions: {},
      };

      if (record.creator_id !== creatorId) {
        throw new Error("creator_mismatch");
      }

      const revision = record.latest_revision + 1;
      record.latest_revision = revision;
      record.revisions[String(revision)] = {
        published_at: Math.floor(now / 1000),
        level,
      };
      this.state.levels[publicId] = record;
      this.state.client_index[clientKey] = publicId;
      this.state.stats[publicId] ??= { plays: 0, likes: 0, curated: false, takedown: false };

      await this.#persist();
      return this.#entry(publicId, revision);
    });
  }

  async getRevision(publicId, revision) {
    const record = this.state.levels[publicId];
    if (!record || !record.revisions[String(revision)]) return null;
    if (this.state.stats[publicId]?.takedown) return null;
    return this.#entry(publicId, revision);
  }

  async listFeed(feed) {
    if (!FEEDS.has(feed)) throw new Error("invalid_feed");

    const entries = Object.entries(this.state.levels)
      .filter(([publicId]) => !this.state.stats[publicId]?.takedown)
      .map(([publicId, record]) => this.#entry(publicId, record.latest_revision));

    if (feed === "curated") {
      return entries
        .filter((entry) => this.state.stats[entry.public_id]?.curated)
        .sort(compareNew);
    }
    if (feed === "popular") {
      return entries.sort((a, b) =>
        b.stats.likes - a.stats.likes || b.stats.plays - a.stats.plays || compareNew(a, b));
    }
    if (feed === "trending") {
      return entries.sort((a, b) => trendingScore(b) - trendingScore(a) || compareNew(a, b));
    }
    return entries.sort(compareNew);
  }

  #entry(publicId, revision) {
    const record = this.state.levels[publicId];
    const snapshot = record.revisions[String(revision)];
    const stats = this.state.stats[publicId] ?? { plays: 0, likes: 0 };
    return {
      public_id: publicId,
      revision,
      creator_id: record.creator_id,
      published_at: snapshot.published_at,
      stats: { plays: stats.plays ?? 0, likes: stats.likes ?? 0 },
      level: structuredClone(snapshot.level),
    };
  }

  async #serialized(fn) {
    const run = this.queue.then(fn, fn);
    this.queue = run.then(() => undefined, () => undefined);
    return run;
  }

  async #persist() {
    await mkdir(dirname(this.filePath), { recursive: true });
    const tempPath = `${this.filePath}.${process.pid}.tmp`;
    await writeFile(tempPath, `${JSON.stringify(this.state, null, 2)}\n`, "utf8");
    await rename(tempPath, this.filePath);
  }
}

function normalizeState(value) {
  if (!value || value.version !== 1) throw new Error("Unsupported community store version.");
  return {
    version: 1,
    levels: value.levels ?? {},
    client_index: value.client_index ?? {},
    stats: value.stats ?? {},
  };
}

function makePublicId() {
  return `ERROW-${randomBytes(6).toString("hex").toUpperCase()}`;
}

function compareNew(a, b) {
  return b.published_at - a.published_at || b.public_id.localeCompare(a.public_id);
}

function trendingScore(entry) {
  const ageHours = Math.max(1, (Date.now() / 1000 - entry.published_at) / 3600);
  return (entry.stats.likes * 3 + entry.stats.plays + 1) / Math.pow(ageHours, 0.45);
}
