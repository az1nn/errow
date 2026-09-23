# SIGA — Errow repository continuation

## Scope

This skill is canonical only for the Errow repository that contains it. It must never import state, SHAs, PR numbers, milestones, URLs, lore, or assumptions from another game.

Standalone trigger: **Siga**

Core invariant:

REAL REPOSITORY STATE > REPOSITORY HANDOFFS / CANON / SPECS > CHAT OR MODEL MEMORY

Continuation state is persisted only in docs/SIGA-HANDOFF.md.

## VERIFY FIRST

Before any mutation:

1. Confirm repository identity and default branch.
2. Confirm project.godot exists. If not, report GODOT_REPO_MISMATCH and stop without mutation.
3. Resolve the exact live HEAD.
4. Discover the Godot version from repository configuration or CI when present.
5. Inspect relevant scenes, scripts, autoloads, Resources, tests and validators.
6. Inspect active branches, open PRs, GitHub Actions/checks, specs/roadmap and existing handoffs.
7. Inspect export_presets.cfg and Web/deployment configuration when present.
8. Resolve the playable URL and deployed commit only from direct evidence when browser delivery is relevant.
9. Never reuse CI evidence from a different HEAD.

## RECONCILE -> DECIDE -> EXECUTE -> PERSIST

Every standalone Siga run follows this sequence.

### RESUME

Use when unfinished repository work exists: incomplete implementation, failing gate, open workstream that still requires code or documentation, or broken required delivery.

Continue from the last verified safe boundary. Do not create a parallel workstream.

### WATCH

Use only when the work is already dispatched and the remaining condition is genuinely external or asynchronous, such as a running CI job, deployment, merge processing or review gate.

Do not duplicate the work. Consume completed results and fix actionable failures. Never describe stale CI as current.

### ADVANCE

Use only when prior work is verifiably complete and the repository contains a supported next milestone, task, issue, spec or handoff direction.

Do not invent a milestone merely to stay busy.

## EXECUTION RULES

- Work on one coherent wave at a time.
- Discover repository commands instead of inventing them.
- Bind every gate claim to the exact relevant HEAD.
- Preserve target-local architecture and gameplay invariants.
- SIGA may advance gameplay, architecture, refactors, bugs, tests, scenes, Resources, save/load, migrations, CI, Web export, deployment, documentation and delivery when supported by repository state.
- Human visual/device testing is asynchronous unless the repository or user explicitly makes it a blocking gate.
- If an engineering dependency is discovered during a lore-only task, leave that implementation to a later Siga run.

## GODOT VERIFICATION

Use only checks that exist or are justified by this repository. Current repository capabilities include, when applicable:

- Node community service tests;
- PostgreSQL integration in GitHub Actions;
- Godot headless import/parse;
- tests/smoke.gd;
- save/load round-trip coverage inside the smoke suite;
- Web release export;
- production community-service container build;
- GitHub Pages deployment on master.

The repository CI contract is documented in docs/CI-CD.md. Re-discover it on each run because it may change.

Never claim a check ran when it did not.

## WEB DELIVERY

When Web delivery is part of the active acceptance boundary, reconcile:

- export_presets.cfg;
- Web export settings;
- CI export workflow;
- deployment provider;
- preview/stable deployment state;
- playable URL;
- exact deployed commit.

Use RESUME for required broken/missing delivery, WATCH for an active build/deploy, and ADVANCE only after required delivery gates are verified.

If Web delivery is not part of the current milestone, its absence is not automatically a failure.

## PERSIST

At the end of a coherent wave update docs/SIGA-HANDOFF.md with only verified Errow state.

The handoff is evidence about a verified point in time, not permission to skip reconciliation. A commit that publishes a handoff necessarily changes repository HEAD, so the next Siga run must always resolve the live HEAD again before using any recorded gate evidence.

Do not create a second SIGA handoff under .agents, memory, Library or another repository.

## FINAL INVARIANT

ONE GAME = ONE REPOSITORY = ONE SIGA STATE = ONE LORE STATE
