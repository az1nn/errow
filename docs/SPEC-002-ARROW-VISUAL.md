# SPEC-002 — Reusable Arrow Visual

## Goal

Replace font-dependent arrow glyphs with a dedicated reusable visual component while preserving the existing puzzle rules, touch target and CI contract.

## Scope

- Add a reusable `ArrowVisual` Godot control.
- Render all four directions from geometry rather than Unicode glyphs.
- Keep the full button surface as the interactive touch target.
- Keep the current board, levels, blocking logic, counters and progression unchanged.
- Require no external art or font asset.

## Acceptance criteria

- Every active board arrow contains an `ArrowVisual` child.
- `ArrowVisual` accepts `U`, `R`, `D` and `L` directions.
- Rendering is vector-based and scales with the control size.
- The visual ignores pointer input so the parent button owns interaction.
- Existing blocked/success feedback continues to modulate the whole button.
- Headless smoke tests verify the reusable component is wired into the real main scene.
- Godot import/parse, smoke tests and Web export remain green.

## Non-goals

- Escape/movement animation.
- Haptics.
- New levels.
- Reworking the level-data format.
- Visual tuning based on phone/browser screenshots.

## Verification

The exact PR HEAD must pass the repository Godot CI/CD workflow. Human visual checks remain asynchronous under `docs/HUMAN-TESTS.md`.

## Next

After this visual primitive is stable, the next independent gameplay enhancement is movement/escape animation and optional supported-device haptics.
