CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-006 — Community service core
STATE: IMPLEMENTED on feature branch; local Node verification green; GitHub PR/CI pending
MODE: RESUME
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-006-COMMUNITY-SERVICE-CORE.md + docs/COMMUNITY-API.md

CURRENT VERSION / HEAD: feat/006-community-service-core; resolve live HEAD during VERIFY-FIRST
BASE: master @ df84bf50ff66090e50dfce13f253746cd6e5e400
BRANCH / ENV: feat/006-community-service-core / PR validation
PR / MR / TASK: create PR to master and validate exact HEAD
SPEC / ADR: SPEC-006-COMMUNITY-SERVICE-CORE

DONE:
- Reconciled SPEC-005 post-merge workflow and GitHub Pages deployment: run 35850518621 succeeded on master HEAD df84bf50ff66090e50dfce13f253746cd6e5e400.
- Added provider-neutral Node.js 22 community service core.
- Implemented authenticated publication through deployment-configured bearer-token mapping.
- Ported 5x5 structural and deterministic solvability validation to the server.
- Added sanitization so client-only id/source fields never enter published revision payloads.
- Added canonical public IDs and immutable revision sequencing scoped by creator + client_level_id.
- Added atomic JSON-file persistence with mutable stats/moderation state separated from revision payloads.
- Added New/Popular/Trending/Curated read feeds and immutable revision reads.
- Added Node tests for auth, validation, deadlock rejection, revision immutability, feeds and persistence.
- Extended repository CI so service tests run against the exact source SHA alongside Godot validation.
- Kept the existing Godot Pages deployment path; deploy now also depends on the service test job.

VERIFY:
- Local Node 22 test suite: 6 tests passed, 0 failed.
- SPEC-005 post-merge master run 35850518621: Community predecessor Godot pipeline and Deploy Web to GitHub Pages were SUCCESS before this workstream started.
- Exact feature HEAD GitHub Actions validation is still pending.

GATES:
- Blocking: exact feature HEAD GitHub Actions must pass both Community service tests and Godot validate/export.
- No explicit human gate.
- Automatic merge authorization remains active under SKILL.md conditions.

BLOCKERS:
- No code blocker known.
- This increment does not choose or provision a production hosting provider.
- The JSON adapter is single-process durable storage; multiple replicas require a shared transactional database adapter.
- Public identity issuance, plays/likes mutation, reports and moderation mutation endpoints remain follow-up work.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone Siga.
- No parallel canonical SIGA state outside this repository.
- Original, Player and Community remain explicit sources.
- Local drafts/offline play remain first-class.
- Never trust client publication validation as authoritative.
- Never load submitted executable Godot resources.
- Published revisions are immutable; mutable stats/moderation remain outside level payloads.
- Do not claim deployment success without direct evidence.

NEXT:
- Create the SPEC-006 PR.
- Validate the exact PR HEAD through the expanded GitHub Actions workflow.
- Fix any Node/Godot/Pages pipeline regression without weakening invariants.
- If exact-head gates are green and the PR is mergeable, merge automatically with expected_head_sha.
- Reconcile master and GitHub Pages after merge.
- Then ADVANCE to production hosting/database + identity, followed by plays/likes and report/takedown mutation APIs.

VERIFY-FIRST:
1. Read this handoff and repository-local SIGA skill.
2. Resolve live feat/006-community-service-core HEAD and PR state.
3. Inspect exact-head GitHub Actions jobs for Community service tests and Godot validate/export.
4. If CI is active, WATCH without duplicating work.
5. If any job failed, RESUME at the failing gate and fix it.
6. If all exact-head gates are green and the PR is mergeable/non-draft with no blocking review, merge under the standing authorization and reconcile master/Pages.
