CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-007 — Production community foundation
STATE: MERGED; exact PR HEAD and post-merge master/Pages gates verified green
MODE: ADVANCE
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-007-PRODUCTION-COMMUNITY-FOUNDATION.md + docs/COMMUNITY-API.md

CURRENT VERSION / HEAD: master; SPEC-007 merge commit 5dd8631c6960fe3d2dc711ab48eed98047676fdd; resolve live HEAD during VERIFY-FIRST
BASE: master
BRANCH / ENV: master / GitHub Pages + provider-neutral OCI community service
PR / MR / TASK: PR #8 — MERGED
SPEC / ADR: SPEC-007-PRODUCTION-COMMUNITY-FOUNDATION

DONE:
- Reconciled the SPEC-006 closure workflow and confirmed master green before starting.
- Added shared PostgreSQL storage for community level identity, immutable revisions and mutable stats/moderation metadata.
- Added transactional publication with creator/client-level uniqueness and row locking for revision allocation.
- Added idempotent PostgreSQL migration under service/migrations/001_init.sql.
- Added production RS256 OIDC/JWKS authentication; validated issuer, audience, subject, expiration, not-before and signature.
- Preserved static-token + JSON-file mode for local development/offline service work.
- Added provider-neutral OCI image through service/Dockerfile.
- Extended CI with PostgreSQL 17 integration testing and production container build.
- Updated Community API, service docs and CI/CD docs without changing the Godot client boundary.
- PR #8 merged under standing authorization with expected_head_sha cf334e8bf03c5fb32307b6b380869d08634b061a.
- Merge commit: 5dd8631c6960fe3d2dc711ab48eed98047676fdd.

VERIFY:
- Local Node suite before push: 8 passed, 0 failed; PostgreSQL integration test skipped locally because TEST_DATABASE_URL was absent.
- PR run 35852525921 on exact HEAD cf334e8bf03c5fb32307b6b380869d08634b061a: SUCCESS.
- PR Community service tests, PostgreSQL integration and OCI image build: SUCCESS.
- PR Godot 4.7.2 import/parse, headless smoke and Web export: SUCCESS.
- PR had no reviews, unresolved threads or comments/blockers immediately before merge.
- Post-merge master run 35852641954 on 5dd8631c6960fe3d2dc711ab48eed98047676fdd: SUCCESS.
- Post-merge Community service/PostgreSQL/container gate: SUCCESS.
- Post-merge Godot validate/export gate: SUCCESS.
- Post-merge Deploy Web to GitHub Pages: SUCCESS.

GATES:
- SPEC-007 technical gates: GREEN.
- No explicit human gate.
- No cloud/provider cost was incurred and no production resource was provisioned.
- This handoff-closing commit may itself trigger the normal master workflow; VERIFY-FIRST must reconcile that latest run before starting the next workstream.

BLOCKERS:
- No code blocker known.
- A concrete production hosting provider, PostgreSQL instance and OIDC provider are not selected or provisioned.
- Provider selection/provisioning may create cost and remains outside this completed increment.
- Plays/likes mutation plus reports/takedown administration remain follow-up work.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone Siga.
- No parallel canonical SIGA state outside this repository.
- Original, Player and Community remain explicit sources.
- Local drafts/offline play remain first-class.
- Never trust client publication validation as authoritative.
- Never load submitted executable Godot resources.
- Published revisions are immutable; mutable stats/moderation remain outside level payloads.
- PostgreSQL production writes must remain transactional.
- Production identity must derive creator identity from a verified external token, never client-supplied creator_id.
- Do not claim production deployment without direct evidence.

NEXT:
- Reconcile the latest master workflow triggered by this handoff closure commit; remain MODE=ADVANCE if green.
- Next logical workstream: SPEC-008 community engagement + moderation mutations.
- Define safe/idempotent play and like semantics, authenticated report submission, moderator takedown/curation controls and auditability without mutating revision payloads.
- Preserve the existing discovery/read/publish client boundary and local/offline behavior.
- Do not provision paid production infrastructure unless a provider/cost decision is explicitly made.

VERIFY-FIRST:
1. Read this handoff and repository-local SIGA skill.
2. Resolve live master HEAD and latest master GitHub Actions run.
3. If the closure workflow is active, WATCH.
4. If it failed, RESUME and fix the failing gate.
5. If it is green, remain ADVANCE.
6. Check for any newly opened PR/issues/reviews before deriving SPEC-008.
