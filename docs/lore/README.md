# Errow Lore Index

This directory is the repository-local index for Errow narrative canon.

## Current canon sources

At the verified bootstrap baseline (master `71caa8cd8fb74b4ed7a62d79389e28c84b431d95`), the repository contains **no dedicated narrative canon document**.

Accordingly, no LORE-BIBLE, CHARACTERS, FACTIONS, LOCATIONS, CAMPAIGN or TIMELINE file is created by this bootstrap. Creating empty ceremonial files would imply narrative structure that the game has not established.

docs/lore/LORE-HANDOFF.md is continuation metadata, not canon.

The existing gameplay/product specs under docs/ and level labels in code describe mechanics and product behavior; they are not silently promoted to fictional-world canon.

## Canon states

Future lore documents must distinguish:

- **CANON** — stable fictional-world fact.
- **RUMOR** — in-world claim that may be false, partial or contradictory.
- **OPEN** — intentionally unresolved question.

RUMOR must not become CANON without an explicit narrative decision. OPEN questions stay open until deliberately resolved.

## Adding a canon source

Create a lore document only when a real narrative wave justifies it, then add it to this index with its purpose and authoritative scope.

The standalone `lore` command must read this index before changing narrative state.
