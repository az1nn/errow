# Errow Community Service

Executable server-side implementation of `docs/COMMUNITY-API.md`.

## Local development

Requires Node.js 22+.

```bash
npm --prefix service install
export ERROW_AUTH_TOKENS='{"local-token":"user-local"}'
export ERROW_ALLOWED_ORIGIN='http://localhost:8060'
npm --prefix service start
```

Without `ERROW_DATABASE_URL`, the service uses the atomic JSON adapter at `service/.data/community.json` (override with `ERROW_DATA_FILE`). This mode is intentionally single-process.

## Production profile

Production is provider-neutral: deploy `service/Dockerfile` as an OCI container and connect it to shared PostgreSQL plus an OIDC issuer.

```bash
export ERROW_DATABASE_URL='postgres://...'
export ERROW_AUTH_MODE='oidc'
export ERROW_OIDC_ISSUER='https://identity.example/'
export ERROW_OIDC_AUDIENCE='errow-community'
export ERROW_OIDC_JWKS_URL='https://identity.example/.well-known/jwks.json'
export ERROW_ALLOWED_ORIGIN='https://game.example'

npm --prefix service run migrate
npm --prefix service start
```

`ERROW_DATABASE_SSL=disable` is intended only for local/test PostgreSQL where TLS is deliberately unavailable. `ERROW_DATABASE_POOL_MAX` defaults to 10.

The OIDC subject (`sub`) becomes the canonical creator ID. Production tokens must be RS256-signed and satisfy issuer, audience, expiry and not-before validation.

Moderator mutations additionally require `ERROW_MODERATOR_IDS`, a comma-separated set of authenticated subject IDs allowed to curate or take down Community levels.

## Current endpoints

- `GET /healthz`
- `GET /v1/levels?feed=new|popular|trending|curated`
- `GET /v1/levels/{public_id}/revisions/{revision}`
- `POST /v1/levels`
- `POST /v1/levels/{public_id}/plays`
- `PUT /v1/levels/{public_id}/like`
- `POST /v1/levels/{public_id}/reports`
- `PATCH /v1/moderation/levels/{public_id}`

## Invariants

- Client validation is never trusted as the publication authority.
- Schema, board geometry, duplicate occupancy and deterministic solvability are checked again server-side.
- `client_level_id` is scoped to the authenticated creator.
- Republishing the same creator/client ID creates the next immutable revision under the same public ID.
- PostgreSQL publication is transactional and serializes the creator/client-level stream.
- Client-only fields such as `id` and `source` do not enter the published level payload.
- Community stats and moderation state remain outside immutable revision payloads.
- Takedown state is respected by read paths.

## Tests

```bash
npm --prefix service test
```

CI additionally supplies `TEST_DATABASE_URL` so the PostgreSQL adapter is exercised against a real database.
