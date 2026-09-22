# SPEC-004 — Player-created levels

## Goal

Let Errow players create, save, validate and playtest their own 5x5 arrow puzzles without requiring a developer-authored code change for every new level.

This is the first UGC slice. It deliberately separates the level format and rules from distribution so the same player level can later be published to an online community service without changing the gameplay runtime.

## Product model

Errow now has two explicit level sources:

- Original: bundled, curated levels shipped with the game.
- Player: levels authored by players using the in-game creator.

The creator is part of the game. A player taps a board cell to cycle through empty, up, right, down and left states.

## Level schema v1

Every level is plain data:

- schema_version: 1
- id: stable identifier
- source: official or player
- name
- subtitle
- board_size: 5
- arrows: list of [x, y, direction]
- created_at / updated_at for persisted player levels

The gameplay scene consumes this schema for both original and player levels.

## Rules and validation

A shared LevelRules module owns:

- structural validation;
- coordinate and direction validation;
- conversion to runtime occupancy;
- the can-exit rule;
- solvability detection.

Solvability is monotonic. Removing an arrow can only remove blockers, never create a new blocker. The solver repeatedly removes any arrow that currently has a clear path. If arrows remain and no arrow can leave, the level is deadlocked.

This gives deterministic validation without brute-force search.

## Persistence

Player drafts are serialized as JSON to user://community_levels.json through LocalLevelStore.

The storage boundary is intentionally separate from gameplay and the creator. A future remote provider can expose the same level dictionaries over HTTP without changing LevelRules or the board runtime.

## Creator flow

1. Create or load a draft.
2. Tap cells to cycle arrow direction.
3. Save draft locally.
4. Run structural and deadlock validation.
5. Playtest a solvable draft in the real gameplay scene.
6. Return to Original or My levels.

Drafts may be saved while deadlocked so the player can continue editing. Only solvable levels appear in the playable My levels collection and only solvable levels can enter playtest.

## Future publish flow

A networked community release should add a provider behind the storage/catalog boundary:

- authenticate player;
- upload a schema-v1 level;
- validate server-side with the same invariants;
- assign canonical public ID and immutable revision;
- expose New, Popular and curated feeds;
- record plays, likes/ratings and reports;
- support moderation and takedown without mutating local drafts.

The client should exchange JSON over HTTPS. It must never require loading arbitrary scripts or executable Godot resources from player submissions.

## Acceptance criteria

- Original levels are data-backed and remain playable.
- The main game exposes Original, My levels and Create.
- The creator supports all 25 cells and all four directions.
- Player drafts survive process restarts through user:// storage.
- Invalid coordinates, duplicate occupancy and invalid directions are rejected.
- A deadlocked level is detected deterministically.
- Solvable player levels can be playtested in the same runtime used by original levels.
- Solvable saved player levels appear in My levels.
- Existing escape animation, blocking rules and progression remain intact.
- Headless tests cover level validation, deadlock detection and JSON round-trip persistence.
- Godot import/parse, smoke tests and Web export remain green.

## Non-goals for this slice

- Accounts or authentication.
- Public upload/download.
- Ratings, comments, follows or reports.
- Remote moderation.
- Matchmaking.
- Procedural generation.
- Variable board sizes.

## Research basis

Patterns reviewed before the implementation:

- Super Mario Maker 2 separates Nintendo-authored Story Mode from player-made Course World, with New/Popular discovery, tags and IDs:
  https://supermariomaker.nintendo.com/news/course-world-tips/
  https://supermariomaker.nintendo.com/play/
- Portal 2's Perpetual Testing Initiative paired a simplified in-game puzzle maker with direct Workshop publishing and browsing:
  https://store.steampowered.com/news/?enddate=1483257600&feed=portal2_blog
- Trackmania separates authored/uploaded/favorite tracks and provides review/curation flows for community maps:
  https://doc.trackmania.com/web/tm-com/player-tracks/
  https://doc.trackmania.com/create/map-review/what-is-map-review/
- Godot documents user:// as writable persistent user storage and JSON as a save/network serialization format:
  https://docs.godotengine.org/pt-br/4.x/tutorials/io/data_paths.html
  https://docs.godotengine.org/en/4.4/classes/class_json.html

## Next

After this local creator foundation is stable, add the online CommunityLevelProvider and discovery UI without changing the schema or gameplay rules.
