# Errow

A small arrow-clearing puzzle built with Godot for mobile and web.

## MVP rule

Tap an arrow when its path to the edge of the 5×5 board is clear. If another arrow is anywhere in front of it, the move is blocked. Clear every arrow to finish the level.

The first playable slice contains three starter levels:

1. **First Escape**
2. **Queue**
3. **Cross Traffic**

## Run locally

1. Install Godot 4.x.
2. Clone this repository.
3. Open `project.godot` in the editor.
4. Run the project.

Main scene: `res://src/main.tscn`

## Project state

- Platform target: mobile + web.
- Rendering: Godot compatibility renderer.
- Current spec: `docs/SPEC-001-PLAYABLE-MVP.md`.
- Continuation protocol: `.agents/skills/siga/`.
