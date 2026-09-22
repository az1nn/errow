CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-001 — Playable MVP + Godot CI/CD
STATE: playable MVP implemented; CI/CD operational; human tests async; automatic merge authorization persisted; PR #2 Ready for Review pending current exact-HEAD CI
MODE: WATCH
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-001-PLAYABLE-MVP.md + docs/CI-CD.md + docs/HUMAN-TESTS.md

CURRENT VERSION / HEAD: resolve live PR #2 HEAD during VERIFY-FIRST; latest authorization commit before this handoff was db5cc91d28adf4666d26736e87566efcba7dfaf1
BASE: master @ fdee9639bf87eaffd1f2b7975e6a930786cc33f7
BRANCH / ENV: feat/001-playable-mvp
PR / MR / TASK: PR #2 — feat: playable Errow MVP — READY FOR REVIEW
SPEC / ADR: SPEC-001-PLAYABLE-MVP

DONE:
- Human visual/device/gameplay testing is asynchronous and non-blocking by default.
- PR #2 is Ready for Review.
- User authorized automatic merge for Errow whenever all applicable tests and verifications pass.
- Repository-local SIGA skill now persists the automatic merge contract.
- Automatic merge requires an open, non-draft, mergeable PR; exact live HEAD resolution; all applicable tests/checks/workflows green; no active jobs, blockers, or change-request reviews; and no exceptional user-declared gate.
- Merge must use expected_head_sha.
- Post-merge master workflows/deployments must be reconciled and consumed.

VERIFY:
- Previous exact HEAD 9285200178ba47cc0dbafd272e9677a1ed9deb06 passed Godot CI/CD run 35722078032.
- That run passed exact checkout, Godot setup/version, import/parse, headless scene smoke tests, Web export and artifact upload.
- Policy commits after that run create a new PR HEAD, so current exact-HEAD CI must complete before automatic merge.
- Human-test absence is not a blocker.

GATES:
- Automated exact-HEAD CI is the blocking engineering gate.
- Merge is no longer a human gate when the persisted automatic-merge conditions are satisfied.
- Human visual/device/gameplay tests remain asynchronous unless the user explicitly declares a specific exception.
- GitHub Pages is only considered deployed after a successful master deploy job.

BLOCKERS:
- No known implementation blocker.
- Waiting only for current exact-HEAD CI triggered by the authorization/handoff changes.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone `Siga`.
- Exactly one of RESUME / WATCH / ADVANCE after reconciliation.
- No parallel canonical SIGA state outside this repository.
- Do not merge stale HEADs: use expected_head_sha.
- Do not merge while a relevant test/check/job is failing or active.
- Do not invent implicit human gates.
- After automatic merge, verify master CI/deploy before advancing.

NEXT:
- Resolve PR #2 live HEAD and consume Godot CI/CD for that exact SHA.
- If CI fails, RESUME and fix PR #2 in place.
- If all applicable verification is green and the PR remains mergeable/non-draft, merge PR #2 automatically using expected_head_sha.
- Reconcile master after merge.
- Consume master Godot CI/CD and GitHub Pages deployment.
- If post-merge gates succeed, classify ADVANCE to the next gameplay workstream.
- If Pages setup prevents deployment, report the concrete infrastructure blocker without reverting the successful code merge.

VERIFY-FIRST:
1. Read this handoff and repository-local SIGA skill.
2. Inspect PR #2 and resolve its exact live HEAD.
3. Inspect all current tests/checks/workflows/reviews/blockers for that HEAD.
4. If merge conditions are satisfied, merge automatically with expected_head_sha.
5. Resolve the new master HEAD.
6. Inspect master CI/CD and Pages deployment.
7. Fix failures when possible.
8. Classify RESUME, WATCH, or ADVANCE from the reconciled state.
