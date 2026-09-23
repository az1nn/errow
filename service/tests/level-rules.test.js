import test from "node:test";
import assert from "node:assert/strict";
import { isSolvable, sanitizeLevel, validateLevel } from "../src/level-rules.js";

const valid = {
  schema_version: 1,
  name: "First publish",
  subtitle: "Server validated",
  board_size: 5,
  arrows: [[0, 0, "L"]],
};

test("accepts a valid solvable 5x5 level", () => {
  assert.equal(validateLevel(valid), "");
  assert.equal(isSolvable(valid), true);
});

test("rejects a deterministic deadlock", () => {
  const deadlocked = { ...valid, arrows: [[0, 0, "R"], [1, 0, "L"]] };
  assert.equal(validateLevel(deadlocked), "");
  assert.equal(isSolvable(deadlocked), false);
});

test("sanitizes client-only level fields", () => {
  const sanitized = sanitizeLevel({ ...valid, id: "local-1", source: "player" });
  assert.equal(sanitized.id, undefined);
  assert.equal(sanitized.source, undefined);
  assert.deepEqual(sanitized.arrows, [[0, 0, "L"]]);
});
