# SPEC-003 — Escape Animation

## Goal

Make every successful move visibly leave the board in its arrow direction before the puzzle state removes that arrow.

## Scope

- Animate the real arrow button away from the board along its configured direction.
- Fade the escaping arrow while it moves.
- Remove the arrow from puzzle state only after the escape animation completes.
- Serialize successful arrow interactions while one escape animation is active.
- Cancel any in-flight escape animation when restarting or changing levels.
- Preserve the existing blocking rule, levels, counters, vector ArrowVisual and CI/CD contract.

## Acceptance criteria

- A clear arrow is disabled immediately after a successful tap.
- The escaping button is reparented to a dedicated overlay layer without visually jumping.
- U/R/D/L arrows move in their matching direction.
- The button fades while moving and is removed after the animation.
- `active_arrows` is unchanged during the animation and is updated after completion.
- A second arrow tap cannot start another escape while one is active.
- Restarting or changing level cancels the active tween and cannot remove an arrow from the newly loaded board.
- Blocked-arrow feedback remains unchanged.
- Headless smoke coverage verifies the computed escape direction, deferred state removal and stale-callback protection.
- Godot import/parse, smoke tests and Web export remain green.

## Non-goals

- Haptics.
- New levels.
- Level-data extraction.
- Particle effects, trails or sound.
- Screenshot-driven visual tuning.

## Verification

The exact PR HEAD must pass the repository Godot CI/CD workflow. Human visual, browser, touch and gameplay-feel checks remain asynchronous under `docs/HUMAN-TESTS.md`.

## Next

After the escape interaction is stable, separate level data from the main scene script before expanding the board catalog.
