# SPEC-007 — Production community foundation

## Goal

Make the SPEC-006 community service safe to run as a horizontally scalable production service without coupling Errow to one cloud vendor.

The deployable target is a standard OCI container backed by shared PostgreSQL and an external OIDC issuer. Selecting or purchasing a concrete cloud provider remains an operational decision outside this increment.

## Scope

- add a PostgreSQL store implementing the existing publish/read/feed contract;
- preserve immutable revision semantics under concurrent publishers;
- add an idempotent schema migration;
- validate RS256 OIDC bearer tokens against configured issuer, audience and JWKS;
- keep static token mapping for local development only;
- select JSON or PostgreSQL storage by environment configuration;
- package the service as a production container;
- exercise PostgreSQL against a real database in CI;
- keep the Godot client API boundary unchanged.

## Storage invariants

PostgreSQL separates:

- level identity and creator/client-level uniqueness;
- immutable revision snapshots;
- mutable stats/moderation state.

Publication serializes per `(creator_id, client_level_id)` through row locking. Concurrent publication cannot reuse a revision number or overwrite an existing snapshot.

## Identity invariants

Production auth mode accepts only signed RS256 JWTs that satisfy:

- signature from the configured JWKS `kid`;
- exact configured issuer;
- configured audience;
- non-empty subject;
- valid expiration and not-before claims with bounded clock skew.

The OIDC `sub` is the canonical creator ID. The service does not issue identity tokens itself.

## Deployment contract

Required for a production deployment:

- `ERROW_DATABASE_URL` — PostgreSQL connection string;
- `ERROW_AUTH_MODE=oidc`;
- `ERROW_OIDC_ISSUER`;
- `ERROW_OIDC_AUDIENCE`;
- `ERROW_OIDC_JWKS_URL`;
- `ERROW_ALLOWED_ORIGIN` — deployed game origin.

Optional:

- `ERROW_DATABASE_SSL=disable` for explicitly non-TLS local/test PostgreSQL only;
- `ERROW_DATABASE_POOL_MAX`;
- standard `PORT` and `HOST`.

Before starting the service against a fresh database, run `npm --prefix service run migrate`.

## Acceptance criteria

- Existing JSON/static-token local mode remains functional.
- PostgreSQL adapter implements publish, immutable revision read and all four feeds.
- A second store/process can read data written by the first.
- The database enforces creator/client-level uniqueness and revision uniqueness.
- Publication is transactional.
- Valid RS256 OIDC tokens authenticate as `sub`.
- Wrong issuer/audience, expired tokens, unsupported algorithms and invalid signatures are rejected.
- CI runs service tests with a real PostgreSQL service.
- The production container installs the explicitly pinned PostgreSQL driver before copying application source.
- Godot import, gameplay smoke, Web export and Pages behavior remain unchanged.

## Non-goals

- Choosing a paid hosting vendor or provisioning production resources.
- Implementing signup/login UX inside Godot.
- Likes/plays mutation endpoints.
- Reports, takedown mutation or moderation administration.
- Search, profiles, comments or social graph features.
