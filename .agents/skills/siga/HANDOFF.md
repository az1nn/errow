CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-005 — Community provider contract
STATE: IMPLEMENTED on feature branch; automated validation pending
MODE: RESUME
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-005-COMMUNITY-PROVIDER.md + docs/COMMUNITY-API.md

CURRENT VERSION / HEAD: feat/005-community-provider; resolve live HEAD during VERIFY-FIRST
BASE: master @ 4c9807f04d6a9d95f78bb1b180e32ade29d8f495
BRANCH / ENV: feat/005-community-provider / PR validation
PR / MR / TASK: create PR to master and validate exact HEAD
SPEC / ADR: SPEC-005-COMMUNITY-PROVIDER

DONE:
- Added CommunityLevelProvider as the single client HTTPS boundary.
- Added New/Popular/Trending/Curated feed contract plus immutable revision download and publish request methods.
- Added optional bearer-token support without storing identity inside level schema.
- Added strict remote-entry normalization: published metadata remains outside level dictionaries.
- Remote levels are structurally validated and must be solvable before entering gameplay.
- Added Community navigation to the main game; New is the first discovery feed.
- Missing API configuration is non-fatal and leaves Original/My levels/Create available.
- Added docs/COMMUNITY-API.md with publication, immutable revision and server-side revalidation requirements.
- Added smoke coverage for valid remote normalization, deadlock rejection and publish preflight validation.
- Updated README to describe the third level source and project setting.

VERIFY:
- Code and tests are persisted on the feature branch.
- Godot 4.7.2 import/parse, headless smoke and Web export still require exact-HEAD GitHub Actions validation.

GATES:
- Blocking: exact feature HEAD Godot CI/CD must pass.
- No explicit human gate.
- Automatic merge authorization remains active under SKILL.md conditions.

BLOCKERS:
- Production community service is intentionally not part of SPEC-005.
- No backend URL is configured in the repository by default.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone Siga.
- No parallel canonical SIGA state outside this repository.
- Original, Player and Community remain explicit sources.
- Community metadata does not mutate schema-v1 puzzle data.
- Never load submitted executable Godot resources.
- Server-side publication validation remains mandatory even after client preflight.

NEXT:
- Open the SPEC-005 PR.
- Validate the exact PR HEAD through Godot CI/CD.
- Fix any parser/runtime/export failures without weakening the contract.
- If exact-head gates are green and the PR is mergeable, merge automatically with expected_head_sha.
- Reconcile master and Pages after merge.
- Then ADVANCE to the hosted community service implementation: identity, immutable persistence, search/discovery ranking, plays/likes and report/takedown state.

VERIFY-FIRST:
1. Read this handoff and repository-local SIGA skill.
2. Resolve live feat/005-community-provider HEAD, open PR and Actions state.
3. If CI is active, WATCH without duplicating work.
4. If CI fails, RESUME at the failing gate.
5. If CI is green and PR is mergeable, merge under the standing authorization, then reconcile master.
