# SPEC-005 — Community provider contract

## Goal

Introduce the first network-ready community slice without coupling gameplay to a specific backend implementation.

This increment adds a constrained HTTPS provider contract, remote discovery entry point and deterministic validation for downloaded/published levels while keeping local drafts and offline gameplay first-class.

## Product surface

Errow now recognizes three explicit level collections:

- Original — curated levels bundled with the game.
- My levels — local player drafts stored under user://.
- Community — remotely published immutable level revisions returned by a configured service.

The Community button initially opens the New feed. If no service URL is configured, the client reports that state without breaking Original or My levels.

## Client provider

CommunityLevelProvider is the only network boundary used by the game client.

Initial operations:

- GET /v1/levels?feed=new|popular|trending|curated
- GET /v1/levels/{public_id}/revisions/{revision}
- POST /v1/levels

The provider owns:

- base URL configuration;
- optional bearer authentication;
- HTTP request serialization;
- JSON decoding;
- response-shape validation;
- conversion of published entries into schema-v1 gameplay data;
- rejection of structurally invalid or deadlocked remote levels.

The gameplay runtime consumes only normalized level dictionaries. It never parses arbitrary remote resources.

## Published-entry envelope

Community metadata remains outside the level schema.

A published entry has:

- public_id
- revision
- creator_id
- published_at
- stats
  - plays
  - likes
- level
  - schema_version
  - name
  - subtitle
  - board_size
  - arrows

The client derives a runtime id as {public_id}@r{revision} and source=community.

Popularity, identity, moderation and immutable revision identity therefore do not leak into the portable level schema.

## Publish document

The client sends:

- schema_version
- client_level_id
- level

The level payload contains only the constrained puzzle data required for publication.

Client validation is advisory. The service MUST repeat validation server-side before creating a public revision.

## Server invariants

A production community service must:

1. authenticate the actor for publication;
2. validate schema_version;
3. enforce a 5x5 board;
4. enforce coordinates and U/R/D/L directions;
5. reject duplicate occupancy;
6. reject deadlocked puzzles;
7. bound text fields;
8. assign the canonical public_id;
9. create an immutable positive revision number;
10. never mutate a published revision in place;
11. store plays, likes, reports and takedown state outside the level payload;
12. return only JSON data, never executable Godot scenes/scripts/resources.

Editing a published level creates a new revision.

## Discovery

The first client discovery surface is New.

The transport contract also reserves:

- popular
- trending
- curated

Search by level/creator ID is a follow-up once the production service exists.

## Configuration

The Godot project setting:

errow/community_api_base_url

controls the service origin.

An empty value is valid and means community networking is disabled. Local creator and offline play remain fully available.

For Web builds, the service must use HTTPS and allow the deployed GitHub Pages origin through CORS.

## Acceptance criteria

- CommunityLevelProvider exists behind the current level-schema boundary.
- The provider supports feed, immutable revision download and publish request shapes.
- Invalid feed names are rejected before network access.
- Publish requests reject invalid or deadlocked levels before network access.
- Remote entries are normalized into source=community gameplay levels.
- Invalid/deadlocked remote entries are discarded.
- Community metadata remains outside the level dictionary.
- Main UI exposes Community without changing Original/My levels/Create behavior.
- Missing service configuration produces a readable non-fatal status.
- Smoke tests cover provider normalization and publish validation.
- Godot import/parse, smoke tests and Web export remain green.

## Non-goals

- Hosting the production community API.
- Account signup/login UI.
- Search UI.
- Likes/reports UI.
- Moderation dashboard.
- Server persistence implementation.
- Realtime feeds.
- Comments/follows.
- Changing schema v1.
