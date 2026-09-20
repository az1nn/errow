CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-001 — Playable MVP + Godot CI/CD
STATE: playable MVP implemented; reproducible Godot CI/CD added; exact-HEAD CI revalidation running
MODE: WATCH
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-001-PLAYABLE-MVP.md + docs/CI-CD.md

CURRENT VERSION / HEAD: resolve live PR #2 HEAD during VERIFY-FIRST; this handoff commit becomes the new live HEAD
BASE: master @ fdee9639bf87eaffd1f2b7975e6a930786cc33f7
BRANCH / ENV: feat/001-playable-mvp
PR / MR / TASK: PR #2 — feat: playable Errow MVP — DRAFT
SPEC / ADR: SPEC-001-PLAYABLE-MVP

DONE:
- Reconciled PR #2 before adding CI/CD.
- Added export_presets.cfg for reproducible Web release exports.
- Added tests/smoke.gd to instantiate the real main scene and exercise level/path invariants.
- Added .github/workflows/godot-ci.yml.
- Pinned the pipeline to Godot 4.7.2 stable.
- Switched setup to official Godot release binaries/templates.
- CI checks out the exact pull-request head SHA and asserts git HEAD identity.
- PR pipeline: import/parse -> headless scene smoke tests -> Web export -> artifact upload.
- master pipeline: same validated build -> GitHub Pages artifact -> Pages deploy.
- Added docs/CI-CD.md and aligned README/SPEC-001 with the automated runtime/export boundary.
- First runtime pipeline execution completed green before the exact-HEAD hardening:
  - Godot 4.7.2 installed successfully.
  - project import/parse succeeded.
  - all smoke assertions passed.
  - Web HTML/WASM/PCK export succeeded.
  - Web artifact uploaded successfully.

VERIFY:
- Official Godot current stable release verified as 4.7.2.
- GitHub Pages custom workflow pattern verified against current GitHub documentation.
- First CI run #2 / workflow run 35511543937 completed successfully.
- First run artifact ID: 10605257761.
- First run used the pull-request merge ref, which exposed a same-HEAD evidence weakness.
- Workflow was hardened afterward to checkout and assert github.event.pull_request.head.sha.
- actions/upload-artifact upgraded to v7 to avoid obsolete Node runtime warnings.
- Final exact-HEAD workflow result must be consumed before declaring the current PR HEAD green.

GATES:
- Automated runtime/export gate: pending final exact-HEAD workflow result after this handoff commit.
- Human gameplay/visual gate remains: responsive sizing, glyph quality and touch UX on real browser/device.
- GitHub Pages one-time repository setting may still be required: Settings -> Pages -> Source: GitHub Actions.
- PR #2 remains draft until the intended human review boundary is satisfied.
- Merge remains a human gate.

BLOCKERS:
- No known implementation blocker.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone `Siga`.
- Exactly one of RESUME / WATCH / ADVANCE after reconciliation.
- No parallel canonical SIGA state outside this repository.
- Automated success must be tied to the exact live PR HEAD.
- Do not declare Pages deployed until a master push deploy job succeeds.
- Do not merge a human-gated PR automatically.

NEXT:
- Resolve the live PR #2 HEAD.
- Consume the Godot CI/CD workflow on that exact SHA.
- If CI fails, classify RESUME and fix PR #2 in place.
- If CI succeeds, automated runtime/export gate becomes green and the remaining gate is human visual/gameplay approval.
- After human approval, move PR #2 to Ready for Review; after merge, verify master CI + Pages deployment.

VERIFY-FIRST:
1. Read this handoff from the repository.
2. Inspect master HEAD and open PRs.
3. Inspect PR #2 draft/state and resolve its live head SHA.
4. Inspect Godot CI/CD workflow runs for that exact head SHA.
5. If a run failed, inspect job steps/logs and fix the same branch.
6. If a run succeeded, verify artifact presence.
7. Inspect any new review comments or user runtime/visual evidence.
8. Classify exactly RESUME, WATCH, or ADVANCE.
