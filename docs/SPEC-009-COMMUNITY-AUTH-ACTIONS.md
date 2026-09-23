# SPEC-009 — Authenticated Community actions

## Goal

Expose the authenticated engagement capabilities delivered by SPEC-008 inside the Godot client without coupling Errow to a concrete identity vendor.

This increment introduces a provider-neutral runtime auth-session boundary and Community gameplay controls for like, unlike and report. Anonymous play counting and all offline/local flows remain unchanged.

## Scope

- add a small Godot auth-session boundary that owns a bearer token only in memory;
- allow local/native development to seed that token from `ERROW_COMMUNITY_AUTH_TOKEN`;
- never persist bearer tokens in level data, local level storage or repository configuration;
- pass the active bearer token into `CommunityLevelProvider`;
- show authenticated Community actions only while a Community level is active and a token exists;
- expose explicit Like and Unlike mutations;
- expose report reason selection for the existing bounded report reasons;
- surface successful engagement/report responses through lightweight gameplay status copy;
- extend headless smoke coverage for the session boundary and action visibility;
- keep production identity-provider selection outside this increment.

## Auth-session invariants

- The session stores only the current opaque bearer token.
- Empty/whitespace tokens mean anonymous mode.
- The token is not written to disk by the session.
- `ERROW_COMMUNITY_AUTH_TOKEN` is a development/runtime injection hook, not a production identity strategy.
- A future login/signup integration may call the same session setter after obtaining an OIDC access token.

## Community action UX

Authenticated Community play exposes:

- **Like** — idempotently sets the current user's like state to true.
- **Unlike** — idempotently clears the current user's like state.
- **Report reason** — one of spam, abusive, misleading, broken or other.
- **Report** — submits or updates the current user's report for the active public level.

The controls stay hidden for Original and Player levels and for anonymous Community sessions.

## Acceptance criteria

- The auth session starts anonymous when no runtime token is supplied.
- Setting/clearing a token updates authenticated state deterministically.
- The provider receives the active token but local gameplay remains independent of it.
- Community action controls are hidden for Original/Player content.
- Anonymous Community play still works and continues to record completed plays.
- Authenticated Community levels expose Like, Unlike and Report controls.
- Like/unlike call the existing SPEC-008 endpoint with explicit desired state.
- Reports use only the existing allowed reason set.
- Node service tests, PostgreSQL integration, Godot import/smoke, Web export and Pages behavior remain green on the exact PR HEAD.

## Non-goals

- Selecting or provisioning an OIDC vendor.
- Implementing OAuth/OIDC browser redirect, PKCE, signup or password recovery UX.
- Persisting refresh/access tokens.
- Moderator administration UI.
- Profiles, comments, follows or social graph.
