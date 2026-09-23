# Errow

A small arrow-clearing puzzle built with Godot for mobile and web.

## Core rule

Tap an arrow when its path to the edge of the 5×5 board is clear. If another arrow is anywhere in front of it, the move is blocked. Clear every arrow to finish the level.

Arrows are rendered by a reusable vector ArrowVisual component. Successful moves animate the arrow out of the board in its direction before puzzle state advances.

## Levels

Errow has three explicit level sources:

- **Original** — curated levels bundled with the game.
- **Player** — levels created in-game and stored locally.
- **Community** — immutable published revisions loaded through the constrained HTTPS provider contract.

The starter original set contains:

1. **First Escape**
2. **Queue**
3. **Cross Traffic**

The **Create** flow lets a player build a 5×5 puzzle by cycling cells through empty/up/right/down/left, save drafts locally, validate deadlocks and playtest solvable levels in the real gameplay runtime.

Player drafts are persisted as JSON under Godot's writable user storage. Solvable drafts appear under **My levels**.

The **Community** entry point loads the `New` feed from `CommunityLevelProvider` when a service URL is configured. Completed Community puzzles now record play engagement through the same constrained provider boundary; like/report transport is available for the future authenticated UX. Remote entries are revalidated client-side and converted back into the same schema-v1 gameplay data used by Original and Player levels. An unconfigured service is non-fatal; local/offline play remains available.

## Run locally

1. Install Godot 4.x.
2. Clone this repository.
3. Open `project.godot` in the editor.
4. Run the project.

Main scene: `res://src/main.tscn`

### Community service

The repository contains the provider-neutral Node.js service under `service/`.

Run its tests with:

```bash
npm --prefix service install
npm --prefix service test
```

For local development, static bearer-token mapping plus the JSON store remain available. The production profile uses PostgreSQL and RS256 OIDC identity while preserving the same Community API contract.

See `service/README.md` and `docs/COMMUNITY-API.md`.

## Project state

- Platform target: mobile + web.
- Rendering: Godot compatibility renderer.
- Current spec: `docs/SPEC-008-COMMUNITY-ENGAGEMENT-MODERATION.md`.
- Community API contract: `docs/COMMUNITY-API.md`.
- UGC research: `docs/UGC-RESEARCH.md`.
- Continuation protocol: `.agents/skills/siga/`.

## CI/CD

Pull requests to `master` validate the Node community service, PostgreSQL adapter and Godot 4.7.2 project against the exact PR HEAD. Godot validation includes headless scene smoke tests and a real Web export. Pushes to `master` additionally publish the validated Web artifact to GitHub Pages.

See `docs/CI-CD.md` for the pipeline contract.

## Human testing

Visual, browser and device checks run asynchronously and do not block normal development by default. Use `docs/HUMAN-TESTS.md` to record the tested SHA/build, environment, evidence and follow-up findings.
