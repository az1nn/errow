CAVEMAN HANDOFF v1

APP: Errow
WORKSTREAM: SPEC-005 — Community provider contract
STATE: MERGED; exact PR HEAD verified green; post-merge master/Pages run requires follow-up visibility
MODE: WATCH
CANONICAL SOURCE: .agents/skills/siga/SKILL.md + .agents/skills/siga/HANDOFF.md + docs/SPEC-005-COMMUNITY-PROVIDER.md + docs/COMMUNITY-API.md

CURRENT VERSION / HEAD: resolve live master HEAD during VERIFY-FIRST; SPEC-005 merge commit is 26f96fcd3b3aca877b99b3c071db54f630d37d65
BASE: master
BRANCH / ENV: master / GitHub Pages
PR / MR / TASK: PR #6 — MERGED
SPEC / ADR: SPEC-005-COMMUNITY-PROVIDER

DONE:
- Added CommunityLevelProvider as the single client HTTPS boundary.
- Added New/Popular/Trending/Curated feed contract plus immutable revision download and publish request methods.
- Added optional bearer-token support without storing identity inside level schema.
- Added strict remote-entry normalization; published metadata stays outside level dictionaries.
- Remote entries are structurally validated and must be solvable before entering gameplay.
- Added Community navigation to the main game; New is the first discovery feed.
- Missing API configuration is non-fatal and leaves Original/My levels/Create available.
- Added docs/COMMUNITY-API.md with server-side revalidation and immutable publication requirements.
- Added smoke coverage for remote normalization, deadlock rejection and publish preflight.
- PR #6 merged automatically under the repository-local authorization at exact HEAD 23e8d3e6d64398953be58c846a27106fcd9151d5.
- Merge commit: 26f96fcd3b3aca877b99b3c071db54f630d37d65.

VERIFY:
- Exact PR HEAD Godot CI/CD run 35850278662: SUCCESS.
- Exact PR HEAD checkout, Godot 4.7.2 import/parse, headless smoke tests, Web export and Web artifact upload: SUCCESS.
- PR #6 was mergeable, non-draft, had no reviews, no unresolved review threads and no comments/blockers immediately before merge.
- The current GitHub connector only enumerates pull-request-triggered runs for a commit; it does not expose the post-merge push/Pages run for master, so that deployment is NOT claimed as independently verified in this execution.

GATES:
- Exact PR HEAD technical gates: GREEN.
- No explicit human gate.
- Follow-up gate: observe the master push workflow / GitHub Pages deployment when tooling exposes it.

BLOCKERS:
- No code blocker known.
- Production community service is intentionally outside SPEC-005 and no API base URL is configured by default.
- Post-merge master/Pages status is an observability gap, not a known failure.

INVARIANTS:
- REAL STATE > HANDOFF > MEMORY > CHAT.
- VERIFY-FIRST on every standalone Siga.
- No parallel canonical SIGA state outside this repository.
- Original, Player and Community remain explicit sources.
- Community metadata does not mutate schema-v1 puzzle data.
- Never load submitted executable Godot resources.
- Server-side publication validation remains mandatory even after client preflight.
- Do not claim post-merge deployment success without direct evidence.

NEXT:
- First, reconcile the master push workflow and GitHub Pages deployment associated with the latest master HEAD.
- If that gate is green, classify ADVANCE.
- Then start the hosted community service workstream: authenticated publication, server-side validation, immutable persistence/revisions, discovery/search, plays/likes and report/takedown state.
- Preserve local drafts/offline play as first-class behavior.

VERIFY-FIRST:
1. Read this handoff and repository-local SIGA skill.
2. Resolve live master HEAD and confirm PR #6 remains merged.
3. Inspect any master push/Pages run newer than merge commit 26f96fcd3b3aca877b99b3c071db54f630d37d65.
4. If a run is active, remain WATCH.
5. If it failed, RESUME and fix the failure in the same workstream.
6. If master/Pages is green, switch to ADVANCE and begin the hosted community service increment.
