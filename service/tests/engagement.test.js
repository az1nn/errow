import test from "node:test";
import assert from "node:assert/strict";
import { mkdtemp } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { createServer } from "node:http";
import { once } from "node:events";
import { createApp } from "../src/app.js";
import { JsonFileStore } from "../src/store.js";

async function withService(run) {
  const dir = await mkdtemp(join(tmpdir(), "errow-engagement-"));
  const store = new JsonFileStore(join(dir, "community.json"));
  await store.init();
  const authTokens = new Map([
    ["user-token", "user-1"],
    ["moderator-token", "moderator-1"],
  ]);
  const server = createServer(createApp({
    store,
    authTokens,
    moderatorIds: new Set(["moderator-1"]),
  }));
  server.listen(0, "127.0.0.1");
  await once(server, "listening");
  const port = server.address().port;
  try {
    await run({ baseUrl: "http://127.0.0.1:" + port });
  } finally {
    server.close();
    await once(server, "close");
  }
}

function publication() {
  return {
    schema_version: 1,
    client_level_id: "engagement-fixture",
    level: {
      schema_version: 1,
      id: "engagement-fixture",
      source: "player",
      name: "Engagement fixture",
      subtitle: "Mutable stats stay outside revisions.",
      board_size: 5,
      arrows: [[0, 0, "L"]],
    },
  };
}

async function publish(baseUrl) {
  const response = await fetch(baseUrl + "/v1/levels", {
    method: "POST",
    headers: {
      authorization: "Bearer user-token",
      "content-type": "application/json",
    },
    body: JSON.stringify(publication()),
  });
  assert.equal(response.status, 201);
  return (await response.json()).entry;
}

test("engagement mutations are bounded and moderation controls visibility", async () => {
  await withService(async ({ baseUrl }) => {
    const entry = await publish(baseUrl);
    const publicId = entry.public_id;

    const play = await fetch(baseUrl + "/v1/levels/" + publicId + "/plays", { method: "POST" });
    assert.equal(play.status, 200);
    assert.deepEqual((await play.json()).stats, { plays: 1, likes: 0 });

    const like = (liked) => fetch(baseUrl + "/v1/levels/" + publicId + "/like", {
      method: "PUT",
      headers: {
        authorization: "Bearer user-token",
        "content-type": "application/json",
      },
      body: JSON.stringify({ liked }),
    });

    let response = await like(true);
    assert.equal(response.status, 200);
    assert.deepEqual((await response.json()).stats, { plays: 1, likes: 1, liked: true });

    response = await like(true);
    assert.equal(response.status, 200);
    assert.equal((await response.json()).stats.likes, 1);

    response = await fetch(baseUrl + "/v1/levels/" + publicId + "/reports", {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ reason: "spam" }),
    });
    assert.equal(response.status, 401);

    response = await fetch(baseUrl + "/v1/levels/" + publicId + "/reports", {
      method: "POST",
      headers: {
        authorization: "Bearer user-token",
        "content-type": "application/json",
      },
      body: JSON.stringify({ reason: "spam" }),
    });
    assert.equal(response.status, 202);

    response = await fetch(baseUrl + "/v1/moderation/levels/" + publicId, {
      method: "PATCH",
      headers: {
        authorization: "Bearer user-token",
        "content-type": "application/json",
      },
      body: JSON.stringify({ curated: true }),
    });
    assert.equal(response.status, 403);

    response = await fetch(baseUrl + "/v1/moderation/levels/" + publicId, {
      method: "PATCH",
      headers: {
        authorization: "Bearer moderator-token",
        "content-type": "application/json",
      },
      body: JSON.stringify({ curated: true }),
    });
    assert.equal(response.status, 200);
    let body = await response.json();
    assert.equal(body.moderation.curated, true);
    assert.equal(body.moderation.reports, 1);

    response = await fetch(baseUrl + "/v1/levels?feed=curated");
    assert.equal(response.status, 200);
    assert.equal((await response.json()).levels.length, 1);

    response = await fetch(baseUrl + "/v1/moderation/levels/" + publicId, {
      method: "PATCH",
      headers: {
        authorization: "Bearer moderator-token",
        "content-type": "application/json",
      },
      body: JSON.stringify({ takedown: true }),
    });
    assert.equal(response.status, 200);

    response = await fetch(baseUrl + "/v1/levels?feed=new");
    assert.equal(response.status, 200);
    assert.equal((await response.json()).levels.length, 0);

    response = await fetch(baseUrl + "/v1/levels/" + publicId + "/revisions/1");
    assert.equal(response.status, 404);

    response = await fetch(baseUrl + "/v1/levels/" + publicId + "/plays", { method: "POST" });
    assert.equal(response.status, 404);
  });
});
