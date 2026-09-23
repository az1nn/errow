# SIGA HANDOFF — Errow

## Verified repository

- Repository: az1nn/errow
- Default branch: master
- Reconciled master HEAD: 224fa3fe969e3e7eac1ac5510dce2f4cd31ca09a
- Baseline workflow: Godot CI/CD #42
- Baseline workflow conclusion: success
- Active branch: feat/008-community-engagement-moderation
- Active PR: #9

## Decision

ADVANCE

The live master baseline was green on exact SHA 224fa3fe969e3e7eac1ac5510dce2f4cd31ca09a, there was no open PR, and SPEC-007 explicitly left engagement/moderation mutations as the next supported Community workstream.

## Current milestone

SPEC-008 — Community engagement and moderation.

## Completed this wave

- Added an explicit SPEC-008 before implementation.
- Added anonymous completed-play counting for visible Community levels.
- Added authenticated idempotent like/unlike state per user and level.
- Added authenticated bounded reports with one report per user and level.
- Added moderator-only curation/takedown mutations through configured authenticated subject IDs.
- Persisted equivalent semantics in JSON local mode and PostgreSQL production mode.
- Preserved immutable published revisions; stats/moderation remain mutable side data.
- Added Godot Community provider operations for play, like and report.
- Preserved Community public ID/revision metadata in runtime levels.
- Record a play when a Community puzzle is successfully cleared.
- Extended Node/PostgreSQL and Godot smoke coverage.
- Updated Community API, service docs and README project state.

## Invariants preserved

- Original and Player levels remain local/offline-capable.
- Community submissions remain constrained data, never executable Godot content.
- Published revisions remain immutable.
- Takedown hides levels from feeds and immutable-revision reads.
- Curation affects only the curated feed.
- Repeated like/report state cannot inflate aggregates/queue cardinality.
- Human visual/device validation remains asynchronous and non-blocking.

## Active gate

PR #9 GitHub Actions on the exact live PR HEAD after this handoff commit.

Do not merge using CI evidence from an earlier branch commit.

## Next action

1. Resolve the new exact PR #9 HEAD created by this handoff update.
2. Consume GitHub Actions for that exact SHA.
3. If all blocking jobs succeed and the PR remains mergeable, merge PR #9.
4. Reconcile the resulting master HEAD and its push/deploy workflow before further advancement.

## Boundaries

- REAL REPOSITORY STATE > REPOSITORY HANDOFFS / CANON / SPECS > CHAT OR MODEL MEMORY.
- One repository-local SIGA state only.
- No paid production infrastructure is selected or provisioned by SPEC-008.
- Login/signup UX and moderator UI remain future work.
