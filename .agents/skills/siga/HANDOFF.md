CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-003 — Escape Animation
STATE: IMPLEMENTED ON FEATURE BRANCH; verification/PR state must be resolved live
MODE: RESUME
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-003-ESCAPE-ANIMATION.md

CURRENT VERSION / HEAD: resolve live feature HEAD during VERIFY-FIRST
BASE: master @ 845376cf93c7b62f67663bb63da5ca8903fc17cc
BRANCH / ENV: feat/003-escape-animation / GitHub Actions
PR / MR / TASK: create or resume the SPEC-003 PR
SPEC / ADR: SPEC-003-ESCAPE-ANIMATION

DONE:
- Added the SPEC-003 contract for directional movement/escape animation.
- Successful arrows are reparented to a dedicated EscapeLayer, move in U/R/D/L direction and fade before state removal.
- Successful arrow interactions are serialized while an escape tween is active.
- Restart/level changes kill the active tween and clear escaping visuals to prevent stale callbacks mutating a new board.
- Smoke coverage exercises directional movement, deferred removal and restart cancellation.

VERIFY:
- Exact feature HEAD Godot CI/CD is still required.
- Required gates: Godot import/parse, headless smoke tests, Web export.
- Human visual/device/gameplay testing remains asynchronous and non-blocking by default.

GATES:
- No explicit human gate.
- Automatic merge authorization remains active under SKILL.md conditions.

BLOCKERS:
- None known before CI.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone Siga.
- No parallel canonical SIGA state outside this repository.
- Do not invent implicit human gates.
- Merge only exact verified PR HEAD.

NEXT:
- Create/resume PR for feat/003-escape-animation.
- Resolve exact HEAD, run/inspect CI and fix failures.
- Merge automatically when the repository-local conditions are satisfied.
- Reconcile master and post-merge Pages deployment, then persist a completed handoff.

VERIFY-FIRST:
1. Read this handoff and repository-local SIGA skill.
2. Resolve live feature/master HEAD, open PRs and Actions runs.
3. If CI is pending, WATCH it; if red, RESUME and fix; if green and mergeable, merge with expected_head_sha.
4. After merge, verify master CI/Pages and close the handoff on master.
