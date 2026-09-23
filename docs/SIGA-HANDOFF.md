# SIGA HANDOFF — Errow

## Verified repository

- Repository: az1nn/errow
- Default branch: master
- Reconciled baseline before SPEC-011: ee8a10b322821b4efce1205e519af2beab6abbc7
- SPEC-011 branch: feat/011-community-feed-discovery
- SPEC-011 PR: #12
- Exact validated PR HEAD: 433e906195886165cd06d0255e9e62464127a8f3
- PR workflow: Godot CI/CD #57 (run 35901623852) — success
- Merge commit: 1f85210c19d7070d2a995af1c0d52356ef069185
- Exact merge workflow: Godot CI/CD #58 (run 35901878551) — success
- GitHub Pages deploy on merge workflow: success
- Open PRs after merge reconciliation: none
- Open issues after merge reconciliation: none

## Decision

ADVANCE

The SPEC-010 handoff publication gate was reconciled green on exact master HEAD ee8a10b322821b4efce1205e519af2beab6abbc7. Repository evidence showed that the provider and service already supported New, Popular, Trending and Curated discovery feeds while the Godot UI exposed only New. That bounded gap became SPEC-011.

## Completed milestone

SPEC-011 — Community feed discovery.

## Delivered

- Added `docs/SPEC-011-COMMUNITY-FEED-DISCOVERY.md`.
- Community still opens the New feed by default.
- Added New, Popular, Trending and Curated feed controls generated from `CommunityLevelProvider.ALLOWED_FEEDS`.
- The active feed is runtime UI state only and never enters level schema v1.
- Feed ranking and curation remain server-owned; the client does not duplicate ranking algorithms.
- Community level labels identify the active feed.
- Community completion copy identifies the active feed when a set is cleared.
- Original and Player collections hide Community discovery controls.
- Existing Player publication, Community play counting, likes, reports and offline/local behavior remain intact.
- Godot smoke coverage verifies all four supported feeds, control visibility, active-feed state and feed-aware labeling.
- README now points to SPEC-011.

## Verified PR gates

Exact PR HEAD 433e906195886165cd06d0255e9e62464127a8f3:

- Community service tests: success.
- PostgreSQL 17 integration gate: success.
- Production Community service image build: success.
- Godot 4.7.2 import/parse: success.
- Headless gameplay/feed-discovery smoke tests: success.
- Web release export/artifact: success.
- GitHub Pages deploy: skipped as expected for pull_request events.
- PR #12 was mergeable with no review threads or submitted reviews and was merged without bypassing checks.

## Verified master gates

Exact merge HEAD 1f85210c19d7070d2a995af1c0d52356ef069185:

- Community service tests: success.
- PostgreSQL integration and production OCI image build: success.
- Godot 4.7.2 import/parse: success.
- Headless smoke tests: success.
- Web release export/artifact: success.
- GitHub Pages deployment: success.

## Invariants preserved

- CommunityLevelProvider remains the sole Godot client network boundary.
- Original and Player levels remain local/offline-capable.
- Community failure remains non-fatal to local gameplay.
- Downloaded Community entries remain constrained JSON and are revalidated for structure and deterministic solvability.
- Ranking, engagement, moderation and identity metadata remain outside level schema v1.
- Published revisions remain immutable.
- Bearer tokens remain runtime-only state.
- Feed switching does not mutate level snapshots.
- Human visual/device validation remains asynchronous and non-blocking.

## Current repository state

SPEC-011 is merged and engineering-green on its merge commit. No open PR or issue currently owns the next workstream.

Repository evidence still identifies these future boundaries, subject to fresh reconciliation before any implementation:

- search by public level ID / creator ID;
- OAuth/OIDC login, signup and refresh UX;
- production Community service provisioning/deployment;
- moderator administration UI;
- profiles, comments, follows and social graph.

Do not select one merely from this handoff. The next standalone Siga must re-read real repository state first and choose only a still-supported bounded next milestone.

## Active gate

This handoff publication commit becomes the newest master HEAD and requires exact-SHA master CI plus GitHub Pages deployment reconciliation.

Do not reuse PR #12 workflow #57 or merge workflow #58 as proof for the newer handoff-publication HEAD.

## Next action

1. Resolve live master after this handoff publication.
2. Consume the exact master Community service, Godot/Web and Pages deploy jobs.
3. If green and no unfinished work appears, classify the next run from current repository evidence as RESUME, WATCH or ADVANCE.
4. Select a new milestone only after that reconciliation.

## Boundaries

- REAL REPOSITORY STATE > REPOSITORY HANDOFFS / CANON / SPECS > CHAT OR MODEL MEMORY.
- One repository-local SIGA state only.
- No external identity provider or hosting provider may be invented without an explicit repository decision.
- Human visual/device validation remains asynchronous unless explicitly promoted to a blocking gate.
