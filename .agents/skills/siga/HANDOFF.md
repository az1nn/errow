CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-004 — Player-created levels
STATE: IMPLEMENTED ON FEATURE BRANCH; PR verification pending
MODE: RESUME
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-004-PLAYER-LEVELS.md

CURRENT VERSION / HEAD: resolve live feat/004-player-levels HEAD during VERIFY-FIRST
BASE: master after merged PR #4 (d4826e3654ce3d7468b8bab2b7141aa828dc1e92)
BRANCH / ENV: feat/004-player-levels / GitHub Actions
PR / MR / TASK: create or resume SPEC-004 PR
SPEC / ADR: SPEC-004-PLAYER-LEVELS + UGC-RESEARCH

DONE:
- Researched UGC patterns from Super Mario Maker 2, Portal 2 and Trackmania.
- Extracted original levels into a data-backed LevelCatalog.
- Added shared LevelRules structural validation, can-exit rule and deterministic deadlock solver.
- Added LocalLevelStore JSON persistence under user://.
- Added in-game LevelCreator with 5x5 cell direction cycling, draft save/load and solvability status.
- Added Original / My levels / Create navigation.
- Player playtests use the exact gameplay runtime and escape animation used by original levels.
- Added smoke coverage for catalog, deadlock detection and local JSON round trip.

VERIFY:
- Exact feature HEAD Godot CI/CD is required.
- Required gates: import/parse, headless smoke tests and Web export.
- Human visual/browser/mobile validation remains asynchronous and non-blocking by default.

GATES:
- No explicit human gate.
- Automatic merge authorization remains active under SKILL.md conditions.

BLOCKERS:
- None known before CI.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- No executable player content; community levels are constrained schema-v1 data.
- Original and Player remain separate sources.
- Merge only exact verified PR HEAD.

NEXT:
- Open/resume the SPEC-004 PR.
- Fix any CI findings without weakening validation.
- Merge automatically when exact-head gates pass.
- Reconcile master and post-merge Pages deployment.
- Next product increment: remote CommunityLevelProvider + discovery/publish flow.

VERIFY-FIRST:
1. Read this handoff and repository-local SIGA skill.
2. Resolve live feat/004-player-levels HEAD, PR state and Actions.
3. If red, fix; if active, consume results; if green and mergeable, merge exact HEAD.
4. After merge, verify master and persist a completed handoff.
