# SPEC-001 — Playable MVP

## Goal

Ship the smallest useful Errow build as a real Godot project for mobile and web.

## Core rule

The board is a 5×5 grid of arrows.

A tapped arrow may leave the board only when there is no other arrow anywhere in front of it along its pointing direction. A legal arrow is removed. A blocked arrow stays in place and gives immediate feedback.

The level is complete when the board is empty.

## Acceptance criteria

- Godot 4 project with a configured main scene.
- 5×5 board rendered with touch-friendly controls.
- Directional path validation for up/right/down/left arrows.
- Blocked-tap feedback.
- Successful arrows are removed.
- Remaining-arrow and move counters.
- Restart action.
- Three starter levels with increasing dependency depth.
- Completion overlay and next-level/replay flow.
- No external art dependency for the MVP.
- Baseline responsive viewport suitable for mobile and browser exports.

## Levels

1. **First Escape** — teaches the center-blocking rule.
2. **Queue** — teaches same-lane ordering.
3. **Cross Traffic** — combines horizontal and vertical release chains.

## Verification boundary

GitHub Actions validates the exact pull-request HEAD with Godot 4.7.2 stable: project import/parse, real-scene headless smoke tests, deterministic level assertions and Web export are the blocking engineering gates.

Human checks for visual feel, responsive sizing, glyph rendering quality and touch UX are asynchronous and non-blocking by default. Findings are persisted as issues, PR comments or follow-up tasks under `docs/HUMAN-TESTS.md`; they do not hold the active workstream in WATCH unless the user explicitly declares a specific human gate.

## Next after MVP

- Consume asynchronous human-test findings from real phone/browser sessions.
- Tune board sizing from real phone/browser screenshots when evidence justifies it.
- Replace text glyph arrows with a dedicated reusable arrow visual.
- Add movement/escape animation and haptics where supported.
- Add a level format separate from presentation code.
- Add more boards only after the base mechanic is validated.
