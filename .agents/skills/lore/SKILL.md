# LORE — Errow narrative continuation

## Scope

This skill is canonical only for Errow and is narrative-only.

Standalone trigger: **lore**

Core invariant:

REAL REPOSITORY STATE > REPOSITORY HANDOFFS / CANON / SPECS > CHAT OR MODEL MEMORY

Lore continuation state is persisted only in docs/lore/LORE-HANDOFF.md. Canon sources are indexed by docs/lore/README.md.

## VERIFY FIRST

Before any lore mutation:

1. Confirm this is the Errow repository and project.godot exists. Otherwise report GODOT_REPO_MISMATCH and stop.
2. Resolve the exact live HEAD and any active lore branch/PR/check.
3. Read docs/lore/README.md and every canon source it names.
4. Read docs/lore/LORE-HANDOFF.md.
5. Search target-repository specs, Resources and narrative-facing IDs for relevant continuity constraints.
6. Never import another game's canon, themes, people, places, chronology, milestone state or identifiers.

## RECONCILE -> DECIDE -> EXECUTE ONE NARRATIVE WAVE -> PERSIST

Choose exactly one route.

### LORE-RESUME

Use when unfinished narrative work exists.

### LORE-WATCH

Use when a lore PR, validator, review or other external lore gate is already active.

### LORE-ADVANCE

Use when prior lore work is complete and a repository-supported narrative gap exists that can be advanced without inventing a required human creative decision.

### LORE-BLOCKED

Use when continuation requires a human creative decision, a missing source, or another explicit dependency that should not be guessed.

## ALLOWED LORE WORK

A lore wave may advance:

- worldbuilding;
- characters;
- factions;
- locations;
- chronology;
- campaign structure;
- quests;
- dialogue;
- codex/archive material;
- narrative events;
- lore-facing Resources and IDs;
- continuity;
- historical/cultural research required by the fiction;
- narrative validators.

A standalone lore run must not silently become generic engine refactoring, unrelated UI, generic CI, unrelated save-system work, broad gameplay mechanics or non-narrative roadmap work.

If lore discovers an engineering dependency:

document dependency -> persist lore state -> leave implementation for a future Siga session.

## CANON MODEL

Every narrative assertion must be intentionally handled as one of:

- CANON — stable fictional-world fact.
- RUMOR — diegetic claim that may be false, partial or contradictory.
- OPEN — deliberately unresolved question.

Never silently promote RUMOR to CANON.
Never close OPEN merely to make lore look complete.

Gameplay labels, mechanics, level names and product specs are not automatically narrative canon.

## PERSIST

After one coherent narrative wave:

- update actual canon documents only when justified;
- keep docs/lore/README.md as the index of real canon sources;
- update docs/lore/LORE-HANDOFF.md with the route, canon delta, continuity checks, active gate and next lore action;
- do not generate empty ceremonial lore files.

## FINAL INVARIANT

ONE GAME = ONE REPOSITORY = ONE SIGA STATE = ONE LORE STATE
