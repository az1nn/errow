# SPEC-010 — Player level Community publishing

## Goal

Close the existing creator-to-Community loop by allowing a saved, solvable Player level to be published through the provider-neutral Community API when the runtime has both a configured service and an authenticated bearer session.

This increment uses the publication contract already delivered by SPEC-005/006/007 and the in-memory auth boundary delivered by SPEC-009. It does not select an identity vendor or change level schema v1.

## Scope

- expose a Publish to Community action while a Player level is active;
- keep publication unavailable for Original and Community levels;
- require a configured Community service before exposing the publish action;
- require an authenticated runtime session before exposing or dispatching publication;
- publish only saved Player levels with a stable local `id`;
- reject invalid or deadlocked levels before network access;
- preserve the local Player draft after publication;
- surface the canonical public ID and immutable revision returned by the service;
- preserve the existing server rule that publishing the same creator + `client_level_id` creates the next immutable revision;
- extend headless smoke coverage for the publication surface and client-side publication guards.

## Publication invariants

- The Godot client publishes through `CommunityLevelProvider` only.
- Only `source=player` levels are eligible.
- A level must have a non-empty local `id`; unsaved editor state is never published directly.
- The local ID becomes `client_level_id` and remains stable across later edits/republication of that local draft.
- Publication never mutates the local level into `source=community`.
- Server-assigned `public_id` and `revision` remain Community metadata outside level schema v1.
- Bearer tokens remain runtime-only session state and are never written into local level storage.
- The server remains authoritative for authentication, validation and immutable revision assignment.

## Player UX

For an active Player level:

- if the Community service is not configured, show a non-fatal publishing availability hint;
- if the service is configured but the session is anonymous, show an authentication-required hint;
- if both are available, show **Publish to Community**;
- disable the publish action while a request is in flight;
- on success, show the returned public ID and revision while keeping the player on the local level.

Original and Community play surfaces do not expose this action.

## Acceptance criteria

- `CommunityLevelProvider.publish_level()` refuses anonymous publication before transport.
- `build_publish_document()` refuses non-Player provenance and missing local IDs.
- Existing structural validation and solvability checks remain mandatory.
- Player publication UI is hidden outside Player levels.
- Player publication UI remains unavailable when the Community service is unconfigured.
- Player publication UI remains unavailable for anonymous sessions.
- A configured, authenticated Player session exposes the publish action.
- Successful publication surfaces the canonical public ID and revision.
- The active local Player level remains local after publication.
- Existing Original, Player, Community, engagement and report flows remain unchanged.
- Node service tests, PostgreSQL integration, Godot import/smoke, Web export and Pages behavior remain green on the exact PR HEAD.

## Non-goals

- OAuth/OIDC redirect, PKCE, signup, login or token refresh UX.
- Selecting or provisioning a production identity vendor.
- Deploying the Community service.
- Moderator administration UI.
- Search, profiles, comments, follows or social graph.
- Changing level schema v1.
