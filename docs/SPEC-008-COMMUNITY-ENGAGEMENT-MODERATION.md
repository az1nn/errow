# SPEC-008 — Community engagement and moderation

## Goal

Turn the existing Community feed metadata into a real mutation surface without weakening immutable puzzle revisions or offline/local play.

This increment adds bounded play, like, report and moderator-state mutations behind the existing provider-neutral community service.

## Scope

- count completed Community plays without mutating puzzle revisions;
- allow an authenticated user to set or clear one like per published level;
- allow an authenticated user to submit or update one report per published level;
- allow configured moderator identities to set curation and takedown state;
- persist engagement/moderation in both JSON local mode and PostgreSQL production mode;
- keep feed ranking driven by mutable stats outside immutable level snapshots;
- keep takedown enforcement on feed and immutable-revision read paths;
- expose Godot provider operations for play, like and report;
- record a play when a Community puzzle is actually cleared;
- extend service and Godot smoke coverage.

## API invariants

### Plays

POST /v1/levels/{public_id}/plays

- does not mutate an immutable level revision;
- increments only an existing, non-taken-down level;
- returns the current public stats;
- is intentionally anonymous in v1 so Web play can be counted before identity UX exists.

Ingress rate limiting and abuse controls remain a deployment concern.

### Likes

PUT /v1/levels/{public_id}/like

Request:

    { "liked": true }

- requires bearer authentication;
- is idempotent per authenticated user;
- the aggregate like count changes only when the user's state changes;
- clearing a missing like is also idempotent.

### Reports

POST /v1/levels/{public_id}/reports

Request:

    { "reason": "spam" }

Allowed reasons are: spam, abusive, misleading, broken, other.

- requires bearer authentication;
- one report exists per authenticated user and public level;
- a repeated report updates that user's reason/timestamp rather than inflating the queue;
- report counts are moderator data and are not exposed in public feed entries.

### Moderation

PATCH /v1/moderation/levels/{public_id}

Request may contain either or both:

    { "curated": true, "takedown": false }

- requires bearer authentication;
- requires the authenticated subject to be configured in ERROW_MODERATOR_IDS;
- curation affects only the curated feed;
- takedown removes the level from feed and revision read paths;
- moderation never rewrites immutable revision payloads.

## Storage invariants

PostgreSQL adds:

- community_level_likes(public_id, user_id) with one row per user/level;
- community_level_reports(public_id, reporter_id) with one row per reporter/level.

The JSON adapter stores equivalent mutable maps while preserving atomic serialized persistence.

Aggregate likes remain in community_level_stats for feed ranking. PostgreSQL like mutation locks the stats row and changes the aggregate only when the corresponding user-like row is inserted or deleted.

## Godot boundary

CommunityLevelProvider adds transport methods for:

- record_play(public_id);
- set_like(public_id, liked);
- report_level(public_id, reason).

The current game records a play on successful Community completion. Like/report UI is deliberately deferred until identity UX can supply a bearer token; local Original and Player flows remain independent of Community availability.

## Acceptance criteria

- JSON mode persists play, like, report, curation and takedown state.
- PostgreSQL mode persists the same semantics and enforces one like/report per user and level.
- Repeating the same like state does not inflate counts.
- Repeating a report does not inflate the moderation queue.
- Non-moderators cannot mutate curation or takedown.
- Taken-down levels disappear from feeds and immutable revision reads.
- Curated levels appear in the curated feed.
- Existing publication/revision behavior remains unchanged.
- Godot Community completion can invoke the play mutation without affecting offline/local play.
- Node tests, PostgreSQL integration, Godot headless smoke and Web export remain green on the exact PR HEAD.

## Non-goals

- Building login/signup UX.
- Building moderator administration UI.
- Comments, follows, profiles or social graph.
- Production ingress/rate-limit provider selection.
- Automatic moderation or trust scoring.
