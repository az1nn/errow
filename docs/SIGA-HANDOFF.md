# SIGA HANDOFF — Errow

## Verified repository

- Repository: az1nn/errow
- Default branch: master
- Reconciled baseline HEAD before this wave: bf622271141f7a21577d382ce836123da7cef440
- Baseline workflow: Godot CI/CD #52 — success
- SPEC-010 PR: #11
- Exact validated PR HEAD: 709900d1453e58c83d1d31af9d84985a31bffd4d
- PR workflow: Godot CI/CD #53 (run 35900209557) — success
- Merge commit: a0ad28298a92ada3537050f60a93ef2c001f5be7
- Exact merge workflow: Godot CI/CD #54 (run 35900365223) — success
- GitHub Pages deploy on merge workflow: success

## Decision

ADVANCE

The SPEC-009 handoff publication gate was reconciled green on exact master HEAD bf622271141f7a21577d382ce836123da7cef440. No open PR or issue competed for ownership. Repository evidence already contained the complete server publication contract, stable local Player IDs, the in-memory bearer-session boundary and explicit future creator -> Community publication architecture, so the next coherent product gap was the missing Player publication surface.

## Completed milestone

SPEC-010 — Player level Community publishing.

## Delivered

- Added `docs/SPEC-010-COMMUNITY-PUBLISHING.md` as the current implementation contract.
- Player levels can expose **Publish to Community** when both the Community service and authenticated runtime session are available.
- Original and Community levels never expose the Player publication action.
- Anonymous publication is rejected by `CommunityLevelProvider` before transport.
- Client publication accepts only Player provenance.
- Unsaved Player state without a stable local ID is rejected before transport.
- Existing structural validation and deterministic solvability checks remain mandatory before publication.
- Stable local level IDs are sent as `client_level_id`, preserving the existing immutable revision semantics for later republication.
- Successful publication surfaces the server-assigned public ID and revision while leaving the local Player level unchanged.
- Auth-session changes now refresh both publication and Community engagement UI surfaces.
- Godot smoke coverage validates publication eligibility, provenance, stable IDs and UI visibility boundaries.
- README advanced to SPEC-010.

## Verified PR gates

Exact PR HEAD 709900d1453e58c83d1d31af9d84985a31bffd4d:

- Community service job: success.
- PostgreSQL 17 integration gate: success.
- Production community-service image build: success.
- Godot 4.7.2 import/parse: success.
- Headless gameplay/publication smoke tests: success.
- Web release export/artifact: success.
- GitHub Pages deploy: skipped as expected for pull_request events.
- PR #11 remained mergeable with no review threads or submitted reviews and was merged as a0ad28298a92ada3537050f60a93ef2c001f5be7.

## Verified master gates

Exact merge HEAD a0ad28298a92ada3537050f60a93ef2c001f5be7:

- Community service tests: success.
- Godot/Web validation and release export: success.
- GitHub Pages deployment: success.

## Invariants preserved

- Original and Player levels remain local/offline-capable.
- Community browsing remains non-fatal when the service is unavailable.
- Publishing never converts or overwrites the local Player draft.
- Published revisions remain server-authoritative and immutable.
- Bearer tokens remain runtime-only session state and are not persisted with level data.
- The client remains provider-neutral and does not select an identity vendor.
- Server-side authentication, validation and revision assignment remain authoritative.
- Existing like/report/play behavior remains independent of Player publication.
- Human visual/device validation remains asynchronous and non-blocking.

## Active gate

This handoff publication commit becomes the newest master HEAD and requires exact-SHA master CI plus GitHub Pages deployment reconciliation.

Do not reuse PR #11 or merge workflow #54 evidence as proof for the newer handoff-publication HEAD.

## Next action

1. Resolve live master after this handoff publication.
2. Consume the exact master Community service, Godot/Web and Pages deploy jobs.
3. If green and no unfinished work appears, select the next milestone only from current repository evidence.

## Boundaries

- REAL REPOSITORY STATE > REPOSITORY HANDOFFS / CANON / SPECS > CHAT OR MODEL MEMORY.
- One repository-local SIGA state only.
- OAuth/OIDC browser redirect, PKCE, signup/login and token refresh UX remain future work.
- Production Community service provisioning/deployment remains an operational future decision.
- Moderator administration UI remains future work.
- Search, profiles, comments, follows and social graph remain future work.
