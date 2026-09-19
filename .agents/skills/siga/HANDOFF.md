CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: Bootstrap SIGA protocol
STATE: protocol persisted in PR #1; verification in progress
MODE: WATCH
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md

CURRENT VERSION / HEAD: PR #1 branch chore/siga-protocol
BASE: master @ 4889b6a56c2dd9ba38ebb9c86e673b6cdd256976
BRANCH / ENV: chore/siga-protocol
PR / MR / TASK: PR #1 — chore: add SIGA continuation protocol
SPEC / ADR: SIGA HANDOFF v1

DONE:
- Reconciled repository state directly from GitHub.
- Verified default branch is master.
- Verified master contained only README.md before this workstream.
- Verified no pull requests existed before this workstream.
- Created branch chore/siga-protocol.
- Persisted .agents/skills/siga/SKILL.md.
- Persisted .agents/skills/siga/HANDOFF.md.
- Opened PR #1.

VERIFY:
- Repository and PR state read directly from GitHub.
- PR #1 initially contained exactly two added files for SIGA.
- Re-check current PR HEAD and checks after this handoff update.

GATES:
- merge remains a human action unless explicitly authorized.
- CI/check state must be verified on the latest HEAD.

BLOCKERS:
- none known; verification pending.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone `Siga`.
- Exactly one of RESUME / WATCH / ADVANCE after reconciliation.
- No parallel canonical SIGA state outside this repository.
- Do not duplicate active work.
- Do not declare green gates without same-HEAD evidence.

NEXT:
- Inspect PR #1 current HEAD.
- Inspect checks/workflow runs on that exact HEAD.
- If validation is complete and green, classify the next session from real state.
- Do not merge automatically without explicit authorization.

VERIFY-FIRST:
1. Read this handoff from the repository.
2. Inspect az1nn/errow default branch and open PRs.
3. Inspect PR #1 and branch chore/siga-protocol.
4. Resolve the current PR HEAD SHA.
5. Inspect checks/workflow runs for that exact SHA.
6. Classify exactly RESUME, WATCH, or ADVANCE from the reconciled state.
