import test from "node:test";
import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { PostgresStore } from "../src/postgres-store.js";

const databaseUrl = process.env.TEST_DATABASE_URL;

test("postgres store preserves immutable revisions across instances", { skip: !databaseUrl }, async () => {
  const pg = await import("pg");
  const pool = new pg.default.Pool({ connectionString: databaseUrl });
  try {
    const sql = await readFile(fileURLToPath(new URL("../migrations/001_init.sql", import.meta.url)), "utf8");
    await pool.query("DROP TABLE IF EXISTS community_level_stats, community_level_revisions, community_levels CASCADE");
    await pool.query(sql);

    const firstStore = new PostgresStore(pool);
    await firstStore.init();
    const levelOne = { schema_version: 1, name: "One", subtitle: "", board_size: 5, arrows: [[0, 0, "L"]] };
    const levelTwo = { ...levelOne, name: "Two" };
    const first = await firstStore.publish({ creatorId: "user-1", clientLevelId: "local-1", level: levelOne, now: 1000 });
    const second = await firstStore.publish({ creatorId: "user-1", clientLevelId: "local-1", level: levelTwo, now: 2000 });

    assert.equal(first.public_id, second.public_id);
    assert.equal(first.revision, 1);
    assert.equal(second.revision, 2);

    const secondStore = new PostgresStore(pool);
    const revisionOne = await secondStore.getRevision(first.public_id, 1);
    assert.equal(revisionOne.level.name, "One");
    const feed = await secondStore.listFeed("new");
    assert.equal(feed.length, 1);
    assert.equal(feed[0].revision, 2);
    assert.equal(feed[0].level.name, "Two");
  } finally {
    await pool.end();
  }
});
