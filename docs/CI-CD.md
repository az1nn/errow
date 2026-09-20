# Godot CI/CD

Errow uses GitHub Actions as the reproducible Godot runtime for repository validation and Web delivery.

## Engine

Pinned version: **Godot 4.7.2 stable**.

The CI runner installs the engine and matching export templates instead of relying on a developer workstation.

## Pull request pipeline

Every pull request targeting `master` runs:

1. Godot installation and version check.
2. Headless editor import/parse.
3. `tests/smoke.gd` against the real main scene.
4. Release export with the `Web` export preset.
5. Verification that the HTML, WASM and PCK outputs exist.
6. Upload of the complete Web build as a GitHub Actions artifact.

A PR should not be treated as runtime-green unless this workflow succeeds on the exact PR HEAD.

## Delivery pipeline

A push to `master` repeats the same validated build and then uploads it as the GitHub Pages artifact.

The deploy job uses the `github-pages` environment and the official GitHub Pages deployment action.

Repository setup requirement: **Settings → Pages → Source: GitHub Actions**. The repository owner must enable that source once if Pages has not already been configured.

## Local parity

With Godot 4.7.2 installed:

```bash
godot --headless --path . --editor --quit
godot --headless --path . --script tests/smoke.gd
mkdir -p build/web
godot --headless --path . --export-release "Web" build/web/index.html
```

## Files

- `.github/workflows/godot-ci.yml` — CI/CD orchestration.
- `export_presets.cfg` — reproducible Web export.
- `tests/smoke.gd` — runtime smoke gate.
- `build/web` — generated output; never committed.
