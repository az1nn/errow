CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: Bootstrap SIGA protocol
STATE: protocol bootstrap in progress
MODE: ADVANCE
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md

CURRENT VERSION / HEAD: branch chore/siga-protocol created from current master
BASE: master
BRANCH / ENV: chore/siga-protocol
PR / MR / TASK: none yet
SPEC / ADR: SIGA HANDOFF v1

DONE:
- Reconciled repository state.
- Verified repository default branch is master.
- Verified master contained only README.md before this workstream.
- Verified no pull requests existed before this workstream.
- Created branch chore/siga-protocol.

VERIFY:
- GitHub repository state read directly before mutation.

GATES:
- none

BLOCKERS:
- none

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone `Siga`.
- Exactly one of RESUME / WATCH / ADVANCE after reconciliation.
- No parallel canonical SIGA state outside this repository.

NEXT:
- Persist SIGA skill.
- Persist this handoff.
- Open and verify a PR for the protocol bootstrap.

VERIFY-FIRST:
1. Read this handoff.
2. Inspect az1nn/errow current default branch and open PRs.
3. Inspect branch chore/siga-protocol if it still exists.
4. Verify current branch HEAD and CI/checks before deciding RESUME/WATCH/ADVANCE.
