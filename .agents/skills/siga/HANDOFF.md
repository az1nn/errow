CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-001 — Playable MVP + Godot CI/CD
STATE: playable MVP implemented; Godot CI/CD operational; human testing converted to async non-blocking work; PR #2 Ready for Review
MODE: WATCH
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-001-PLAYABLE-MVP.md + docs/CI-CD.md + docs/HUMAN-TESTS.md

CURRENT VERSION / HEAD: resolve live PR #2 HEAD during VERIFY-FIRST; latest policy commit before this handoff was b3a80901fa7771a8577ab78d3e3084c8886fa5d3
BASE: master @ fdee9639bf87eaffd1f2b7975e6a930786cc33f7
BRANCH / ENV: feat/001-playable-mvp
PR / MR / TASK: PR #2 — feat: playable Errow MVP — READY FOR REVIEW
SPEC / ADR: SPEC-001-PLAYABLE-MVP

DONE:
- Reconciled PR #2 and removed the implicit human visual/gameplay blocking gate.
- Added docs/HUMAN-TESTS.md with an asynchronous human-test protocol.
- Human test evidence now records SHA/build, device/browser, viewport, result, reproduction, evidence and severity.
- Human findings are persisted as issues, PR comments or follow-up tasks.
- Updated SPEC-001 so automated Godot CI is the blocking engineering gate.
- Updated docs/CI-CD.md and README to separate automated gates from asynchronous human validation.
- Updated the repository-local SIGA skill: pending human testing alone must not cause WATCH or block Ready for Review.
- Marked PR #2 Ready for Review.
- Existing automated runtime/export pipeline remains exact-HEAD Godot 4.7.2 validation.

VERIFY:
- Previous exact HEAD 499038105d524f4ea828f3cbeb1cf74df428450f completed Godot CI/CD run 35721717803 successfully.
- That run passed exact checkout, Godot setup/version, import/parse, scene smoke tests, Web export and artifact upload.
- Artifact 10691845842 was produced for exact HEAD 499038105d524f4ea828f3cbeb1cf74df428450f.
- Policy/documentation commits after that run require current live-HEAD CI verification before merge.
- PR #2 metadata was changed from Draft to Ready for Review.

GATES:
- Human visual/device/gameplay testing is NOT a blocking gate by default.
- Missing human-test evidence must not stall development.
- Automated exact-HEAD CI remains the blocking engineering gate.
- Merge remains an explicit human gate unless separately authorized.
- GitHub Pages is only considered deployed after successful master deployment.

BLOCKERS:
- No human-testing blocker.
- No known implementation blocker.
- Current live-HEAD CI must be consumed before merge.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone `Siga`.
- Exactly one of RESUME / WATCH / ADVANCE after reconciliation.
- No parallel canonical SIGA state outside this repository.
- Do not convert ordinary human testing into an implicit gate.
- Human findings are asynchronous persistent work, not chat-only blockers.
- Do not declare automated success without exact live-HEAD evidence.
- Do not cross explicit merge/production/destructive gates automatically.

NEXT:
- Resolve PR #2 live HEAD and consume Godot CI/CD for that exact SHA.
- If CI fails, classify RESUME and fix the active PR.
- If CI is green and PR #2 remains open, WATCH only for the explicit merge decision; do not wait for human visual testing.
- Human tests may run asynchronously at any time using docs/HUMAN-TESTS.md.
- After PR #2 is merged, verify master CI/Pages and classify ADVANCE to the next gameplay workstream.

VERIFY-FIRST:
1. Read this handoff and the repository-local SIGA skill.
2. Inspect master and PR #2.
3. Resolve the exact PR #2 live HEAD.
4. Inspect Godot CI/CD for that exact SHA.
5. Consume persisted review comments/issues/human-test findings if any.
6. Do not treat absent human-test results as a blocker.
7. If merged and master is verified, ADVANCE.
8. Otherwise classify exactly RESUME or WATCH from the remaining real gates.
