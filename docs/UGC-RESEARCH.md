# UGC architecture research — Errow

## What established games converge on

### Super Mario Maker 2

Nintendo keeps authored content and community content legible as different experiences. Course World adds New, Popular, search filters, tags, course IDs and maker IDs rather than mixing every level into one undifferentiated list.

Errow implication: preserve Original and Player as separate first-class sources, then add discovery views on top of Player content.

### Portal 2

Valve's Perpetual Testing Initiative reduced authoring friction by putting a simplified puzzle maker inside the game and connecting it directly to distribution through Steam Workshop.

Errow implication: the creator must use the same primitives and rules as runtime gameplay; publishing should become a thin distribution step, not a separate editor toolchain.

### Trackmania

Trackmania has explicit author/upload/favorite ownership views plus review and curation surfaces. Community maps can be gathered into campaigns and surfaced through review programs.

Errow implication: ownership, discovery, review and curation are separate concerns. Do not encode popularity or moderation into the level file itself.

## Architecture decision

The durable boundary is the level schema.

Original bundle -> Level schema v1 -> LevelRules -> Gameplay

Player creator -> Level schema v1 -> LevelRules -> LocalLevelStore -> Gameplay

Future:

Player creator -> Level schema v1 -> LevelRules -> CommunityLevelProvider -> HTTPS API -> community catalog

The runtime should not care whether a level came from source control, local storage or a remote service.

## Trust boundary

Community content is untrusted data.

Allow only:

- 5x5 coordinates;
- U/R/D/L direction codes;
- bounded title/subtitle text;
- schema metadata.

Do not load player-submitted GDScript, scenes, resources or arbitrary file paths.

## Publish invariants for the later online phase

Server-side publication should re-run all structural validation and solvability checks even if the client already passed them.

A published revision should be immutable. Editing creates a new revision so ratings, plays, reports and leaderboard data remain attributable to the exact puzzle players saw.

## Discovery model for the later online phase

Useful initial feeds:

- New
- Popular
- Trending
- Curated
- Following
- Search by level ID / creator ID

Popularity should be derived server-side from plays and positive signals rather than stored in level JSON.

## Moderation surface

Errow's constrained level format dramatically reduces content risk because the core map is coordinates and four direction codes. The main moderation surface is free text and account identity, not the puzzle graph.

Keep report/takedown state in the community service rather than mutating level schema v1.
