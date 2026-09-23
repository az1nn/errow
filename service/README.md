# Errow Community Service

Executable server-side implementation of the contract in `docs/COMMUNITY-API.md`.

## Run

Requires Node.js 22+.

```bash
export ERROW_AUTH_TOKENS='{"local-token":"user-local"}'
export ERROW_ALLOWED_ORIGIN='http://localhost:8060'
npm --prefix service start
```

Default listen address: `0.0.0.0:8787`.

Default durable file: `service/.data/community.json`.

Override it with `ERROW_DATA_FILE`.

## Current endpoints

- `GET /healthz`
- `GET /v1/levels?feed=new|popular|trending|curated`
- `GET /v1/levels/{public_id}/revisions/{revision}`
- `POST /v1/levels`

Publication requires `Authorization: Bearer <token>`. Tokens are mapped to creator IDs through the `ERROW_AUTH_TOKENS` JSON object.

## Invariants

- Client validation is never trusted as the publication authority.
- Schema, board geometry, duplicate occupancy and deterministic solvability are checked again server-side.
- `client_level_id` is scoped to the authenticated creator.
- Republishing the same creator/client ID creates the next immutable revision under the same public ID.
- Client-only fields such as `id` and `source` do not enter the published level payload.
- Community stats and moderation state are stored outside immutable revision payloads.
- Takedown state is already respected by read paths, although moderation mutation endpoints are a later increment.

## Storage profile

SPEC-006 deliberately uses one atomic JSON file behind a store boundary. This makes the service runnable without a cloud vendor and provides durable single-process semantics.

It is not a multi-replica database. Production hosting with concurrent replicas must replace this adapter with transactional shared storage while preserving the same domain/API invariants.

## Tests

```bash
npm --prefix service test
```
