import test from "node:test";
import assert from "node:assert/strict";
import { mkdtemp, readFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createServer } from "node:http";
import { once } from "node:events";
import { createApp } from "../src/app.js";
import { JsonFileStore } from "../src/store.js";

async function withService(run) {
  const dir = await mkdtemp(join(tmpdir(), "errow-community-"));
  const file = join(dir, "community.json");
  const store = new JsonFileStore(file);
  await store.init();
  const server = createServer(createApp({ store, authTokens: new Map([["test-token", "user-123"]]) }));
  server.listen(0, "127.0.0.1");
  await once(server, "listening");
  const { port } = server.address();
  try {
    await run({ baseUrl: `http://127.0.0.1:${port}`, file });
  } finally {
    server.close();
    await once(server, "close");
  }
}

const publication = (name) => ({
  schema_version: 1,
  client_level_id: "local-123",
  level: {
    schema_version: 1,
    id: "local-123",
    source: "player",
    name,
    subtitle: "Immutable revision",
    board_size: 5,
    arrows: [[0, 0, "L"]],
  },
});

test("requires authentication for publication", async () => {
  await withService(async ({ baseUrl }) => {
    const response = await fetch(`${baseUrl}/v1/levels`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(publication("No auth")),
    });
    assert.equal(response.status, 401);
  });
});

test("publishes immutable revisions and serves feeds", async () => {
  await withService(async ({ baseUrl, file }) => {
    const publish = (name) => fetch(`${baseUrl}/v1/levels`, {
      method: "POST",
      headers: {
        authorization: "Bearer test-token",
        "content-type": "application/json",
      },
      body: JSON.stringify(publication(name)),
    });

    const first = await publish("Revision one");
    assert.equal(first.status, 201);
    const firstEntry = (await first.json()).entry;
    assert.equal(firstEntry.revision, 1);
    assert.equal(firstEntry.level.id, undefined);
    assert.equal(firstEntry.level.source, undefined);

    const second = await publish("Revision two");
    assert.equal(second.status, 201);
    const secondEntry = (await second.json()).entry;
    assert.equal(secondEntry.public_id, firstEntry.public_id);
    assert.equal(secondEntry.revision, 2);

    const revisionOne = await fetch(`${baseUrl}/v1/levels/${firstEntry.public_id}/revisions/1`);
    assert.equal(revisionOne.status, 200);
    assert.equal((await revisionOne.json()).entry.level.name, "Revision one");

    const feed = await fetch(`${baseUrl}/v1/levels?feed=new`);
    assert.equal(feed.status, 200);
    const levels = (await feed.json()).levels;
    assert.equal(levels.length, 1);
    assert.equal(levels[0].revision, 2);
    assert.equal(levels[0].level.name, "Revision two");

    const persisted = JSON.parse(await readFile(file, "utf8"));
    assert.equal(Object.keys(persisted.levels[firstEntry.public_id].revisions).length, 2);
  });
});

test("repeats deadlock validation on the server", async () => {
  await withService(async ({ baseUrl }) => {
    const payload = publication("Deadlocked");
    payload.level.arrows = [[0, 0, "R"], [1, 0, "L"]];
    const response = await fetch(`${baseUrl}/v1/levels`, {
      method: "POST",
      headers: {
        authorization: "Bearer test-token",
        "content-type": "application/json",
      },
      body: JSON.stringify(payload),
    });
    assert.equal(response.status, 400);
    assert.equal((await response.json()).error.code, "invalid_level");
  });
});
