# SIGA HANDOFF — Errow

## Verified repository

- Repository: az1nn/errow
- Default branch: master
- Reconciled baseline HEAD: 224fa3fe969e3e7eac1ac5510dce2f4cd31ca09a
- Baseline workflow: Godot CI/CD #42 — success
- SPEC-008 PR: #9
- Exact validated PR HEAD: 31823d572c2ec118a486d98ef7eb6c6936986538
- PR workflow: Godot CI/CD #44 — success
- Merge commit: a61c7c94a63c77c4cdedbe7fd911efa1c11a9b0d

## Decision

ADVANCE

The live baseline was green, no competing workstream existed, and SPEC-007 explicitly left Community engagement/moderation mutations as the next supported increment.

## Completed milestone

SPEC-008 — Community engagement and moderation.

## Delivered

- Anonymous completed-play mutation for visible Community levels.
- Authenticated idempotent like/unlike state per user and level.
- Authenticated bounded reports with one report per user and level.
- Moderator-only curation/takedown mutations using configured authenticated subject IDs.
- Equivalent persistence semantics in JSON local mode and PostgreSQL production mode.
- Immutable published revisions preserved; engagement/moderation remain mutable side data.
- Godot provider operations for play, like and report.
- Community public ID/revision retained in runtime level metadata.
- Successful Community completion records a play.
- Node service tests, PostgreSQL integration coverage and Godot smoke coverage extended.
- Community API, service docs and README advanced to SPEC-008.

## Verified PR gates

Exact PR HEAD 31823d572c2ec118a486d98ef7eb6c6936986538:

- Community service tests: success.
- PostgreSQL 17 integration: success.
- Production service container build: success.
- Godot 4.7.2 import/parse: success.
- Headless smoke tests: success.
- Web export/artifact: success.
- PR remained mergeable and was merged as a61c7c94a63c77c4cdedbe7fd911efa1c11a9b0d.

## Invariants preserved

- Original and Player levels remain local/offline-capable.
- Community submissions remain constrained data, never executable Godot content.
- Published revisions remain immutable.
- Takedown hides levels from feeds and immutable-revision reads.
- Curation affects only the curated feed.
- Repeating like/report state cannot inflate aggregates/queue cardinality.
- Human visual/device validation remains asynchronous and non-blocking.

## Active gate

This handoff publication commit becomes the newest master HEAD and therefore requires its own exact-SHA master CI/deploy reconciliation.

Do not reuse PR #9 CI evidence as proof for the newer handoff-publication HEAD.

## Next action

1. Resolve the live master HEAD after this handoff publication.
2. Consume its exact GitHub Actions service, Godot/Web and Pages deployment jobs.
3. If green and no new unfinished work appears, select the next milestone from repository evidence rather than chat memory.

## Boundaries

- REAL REPOSITORY STATE > REPOSITORY HANDOFFS / CANON / SPECS > CHAT OR MODEL MEMORY.
- One repository-local SIGA state only.
- No paid production infrastructure was selected or provisioned.
- Login/signup UX and moderator administration UI remain future work.
