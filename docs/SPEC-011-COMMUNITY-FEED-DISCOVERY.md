# SPEC-011 — Community feed discovery

## Goal

Expose the Community discovery model already supported by the provider and service so players can intentionally browse New, Popular, Trending and Curated levels without changing the level schema or weakening offline play.

## Scope

- add a bounded Community feed selector to the Godot UI;
- expose exactly the feeds already allowed by CommunityLevelProvider: new, popular, trending and curated;
- keep New as the default entry point;
- track the active feed in runtime UI state only;
- identify the active feed in Community level labels and completion copy;
- preserve existing provider validation, immutable revision semantics, engagement actions and Player publishing;
- extend headless smoke coverage for feed controls and active-feed identity.

## Product behavior

The Community button enters the New feed.

While Community browsing is active, the player can switch between:

- New — newest visible published revisions;
- Popular — server-ranked by likes, then plays, then recency;
- Trending — server-ranked by the existing bounded time-decay score;
- Curated — only levels explicitly curated by moderation state.

The client does not reproduce ranking logic. It sends the selected feed name and consumes the ordered response returned by the Community service.

If a feed is empty or the service request fails, Original and Player levels remain available and the feed selector remains usable for another attempt.

## Invariants

- CommunityLevelProvider remains the only game-client network boundary.
- Only provider-declared ALLOWED_FEEDS may be requested.
- Ranking and curation remain server-owned metadata outside level schema v1.
- Downloaded entries still pass client-side structural and deterministic solvability validation.
- A feed switch never mutates Original, Player or Community level snapshots.
- Authenticated likes/reports and Player publication remain independent of feed selection.
- No identity provider, search API, profiles, comments, follows or social graph are introduced.
- Missing Community service configuration remains non-fatal.

## Acceptance criteria

- Community opens New by default.
- New, Popular, Trending and Curated controls are available while browsing Community.
- The active feed control is visibly non-interactive to prevent redundant same-feed requests.
- Successful feed loads switch the runtime collection to Community and identify the active feed in the level label.
- Empty/error states do not break local gameplay or erase other source collections.
- Existing Community publication/engagement behavior remains unchanged.
- Godot headless smoke covers the four supported feeds, control visibility and active-feed labeling.
- Exact-HEAD CI passes Community service tests, PostgreSQL integration, Godot 4.7.2 import/parse, smoke tests and Web export.

## Non-goals

- Search by public level ID or creator ID.
- Login/signup/OIDC UX.
- Moderator administration UI.
- Production Community service provisioning.
- Changes to feed ranking algorithms.
- Changes to level schema v1.
