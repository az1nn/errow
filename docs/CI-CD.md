# Godot CI/CD

Errow uses GitHub Actions as the reproducible Godot runtime for repository validation and Web delivery.

## Engine

Pinned version: **Godot 4.7.2 stable**.

The runner downloads the official Godot Linux binary and matching export templates directly from the Godot GitHub release. CI does not depend on a developer workstation or a preinstalled engine.

## Source identity

For pull requests, the workflow checks out `github.event.pull_request.head.sha` explicitly and verifies that `git rev-parse HEAD` matches it before any runtime gate is accepted.

For pushes to `master`, the validated source is the pushed commit SHA.

This preserves same-HEAD evidence for the repository continuation protocol.

## Pull request pipeline

Every pull request targeting `master` runs:

1. Exact source checkout.
2. Official Godot 4.7.2 stable + export-template installation.
3. Engine version check.
4. Exact-SHA assertion.
5. Headless editor import/parse.
6. `tests/smoke.gd` against the real main scene.
7. Release export with the `Web` preset.
8. Verification that HTML, WASM and PCK outputs exist.
9. Upload of the complete Web build as a GitHub Actions artifact.

A PR is runtime/export-green only when this workflow succeeds on its exact live HEAD.

## Delivery pipeline

A push to `master` repeats the same validated build and uploads the Web output as the GitHub Pages artifact. The deploy job then publishes that artifact through the `github-pages` environment.

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

## Human validation

Human visual/device testing is intentionally asynchronous and non-blocking. It is not part of the default PR gate contract.

Automated CI remains the blocking engineering gate. Device/browser observations are captured separately using `docs/HUMAN-TESTS.md` and converted into persistent follow-up work.

A missing human test result must not, by itself, leave SIGA in `WATCH` or prevent a validated PR from becoming Ready for Review.
