CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: Bootstrap SIGA protocol
STATE: protocol persisted; PR #1 open at human merge gate
MODE: WATCH
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md

CURRENT VERSION / HEAD: resolve current tip of chore/siga-protocol during VERIFY-FIRST; last verified pre-handoff HEAD was 220cdda2334c360f40bea6b0623973bd3fa444f1
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
- Verified PR #1 contains exactly two changed files for the repository-local SIGA protocol.

VERIFY:
- GitHub PR state read directly.
- On pre-handoff HEAD 220cdda2334c360f40bea6b0623973bd3fa444f1:
  - workflow runs: none;
  - combined status checks: none.
- No automated CI gate is configured on that verified HEAD.
- Because this handoff update creates a new commit, next execution must resolve and verify the current branch tip rather than trusting the recorded pre-handoff SHA.

GATES:
- PR #1 merge is a human gate unless explicitly authorized.
- No automated CI/check gate was present on the last verified pre-handoff HEAD.

BLOCKERS:
- none.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone `Siga`.
- Exactly one of RESUME / WATCH / ADVANCE after reconciliation.
- No parallel canonical SIGA state outside this repository.
- Do not duplicate active work.
- Do not declare green gates without same-HEAD evidence.
- Treat a persisted HEAD as a hint; always resolve the live branch/PR HEAD first.

NEXT:
- On the next standalone `Siga`, reconcile PR #1 first.
- If PR #1 remains open with no failing/running checks, remain WATCH at the human merge gate.
- If PR #1 is merged/closed and no other work is active, classify ADVANCE from the repository roadmap/state.
- Do not merge automatically without explicit authorization.

VERIFY-FIRST:
1. Read this handoff from the repository.
2. Inspect az1nn/errow default branch and open PRs.
3. Inspect PR #1 and branch chore/siga-protocol if they still exist.
4. Resolve the live PR/branch HEAD SHA.
5. Inspect workflow runs/status checks for that exact SHA.
6. Inspect review/merge gate state.
7. Classify exactly RESUME, WATCH, or ADVANCE from the reconciled state.
