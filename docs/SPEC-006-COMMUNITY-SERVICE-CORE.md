# SPEC-006 — Community service core

## Goal

Turn the SPEC-005 client contract into an executable server-side service while preserving Errow's constrained-data security boundary and offline-first client behavior.

This increment is intentionally provider-neutral: the service can run anywhere Node.js 22 is available and keeps persistence behind a replaceable store boundary.

## Scope

The service implements:

- GET /healthz
- GET /v1/levels?feed=new|popular|trending|curated
- GET /v1/levels/{public_id}/revisions/{revision}
- POST /v1/levels

Publication requires a bearer token mapped to a creator ID by deployment configuration.

## Server validation

The server repeats publication validation independently of the Godot client:

- schema_version must be 1;
- board_size must be 5;
- title/subtitle are bounded;
- arrows must be constrained [x, y, direction] tuples;
- coordinates must be integers inside the board;
- directions must be U/R/D/L;
- duplicate occupancy is rejected;
- a board must contain 1-25 arrows;
- deterministic deadlocks are rejected.

Client-only fields are stripped before persistence.

## Identity and revision semantics

`client_level_id` is scoped to the authenticated creator.

The first publication for a creator/client ID receives a canonical random public ID and revision 1.

Publishing the same creator/client ID again keeps the public ID and creates revision N+1. Existing revision snapshots are never mutated.

## Persistence

The first adapter is an atomic JSON-file store suitable for a single service process.

State separates:

- immutable revision payloads;
- creator/client ID index;
- mutable stats and moderation flags.

Writes are serialized in-process and persisted through temporary-file + rename replacement.

This adapter is a foundation, not the final horizontal-scaling topology. A shared transactional database adapter is required before running multiple replicas.

## Discovery

- new: latest published revision first;
- popular: likes, then plays, then recency;
- trending: recency-decayed likes/plays score;
- curated: only entries whose mutable metadata is marked curated.

Takedown entries are excluded from feeds and direct revision reads.

Stats/moderation mutation endpoints are not exposed in this increment.

## Configuration

- PORT: HTTP port, default 8787.
- HOST: bind host, default 0.0.0.0.
- ERROW_DATA_FILE: durable JSON path.
- ERROW_ALLOWED_ORIGIN: CORS origin; production should use the deployed game origin.
- ERROW_AUTH_TOKENS: JSON object mapping opaque bearer tokens to creator IDs.

Tokens must be supplied by deployment secrets/environment configuration and must never be committed.

## Acceptance criteria

- The existing Community API read/publish contract is executable.
- Anonymous publication is rejected.
- Server-side validation cannot be bypassed by a client-valid-looking payload.
- Deadlocked levels are rejected before persistence.
- Same creator/client ID creates immutable successive revisions.
- Direct revision reads preserve old snapshots after later publications.
- Feeds return the latest visible revision envelope.
- Durable file state survives store reinitialization.
- Node tests cover auth, validation, revisions, reads and persistence.
- Repository CI runs the service tests alongside Godot validation.
- Godot import/parse, smoke tests, Web export and Pages deployment remain unchanged in behavior.

## Non-goals

- Public account signup/login or OAuth/OIDC integration.
- Cloud-provider selection or production deployment.
- Multi-replica shared database.
- Likes/plays mutation endpoints.
- Report/takedown administration endpoints.
- Search UI or creator profiles.
- Realtime feeds, comments or follows.
