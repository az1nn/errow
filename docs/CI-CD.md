# Godot + Community Service CI/CD

Errow uses GitHub Actions as the reproducible runtime for repository validation and Web delivery.

## Runtime versions

- Godot: **4.7.2 stable**.
- Node.js: **22**.
- PostgreSQL integration gate: **17-alpine** service container.

The runner downloads the official Godot Linux binary and matching export templates directly from the Godot GitHub release. CI does not depend on a developer workstation or a preinstalled engine.

## Source identity

For pull requests, the workflow checks out `github.event.pull_request.head.sha` explicitly and verifies that `git rev-parse HEAD` matches it before any runtime gate is accepted.

For pushes to `master`, the validated source is the pushed commit SHA.

This preserves same-HEAD evidence for the repository continuation protocol.

## Pull request pipeline

Every pull request targeting `master` runs two blocking jobs against the exact source SHA.

### Community service

1. Exact source checkout and SHA assertion.
2. Node.js 22 setup.
3. PostgreSQL 17 ephemeral service startup.
4. Service dependency installation.
5. Node unit/service tests.
6. PostgreSQL integration test through `TEST_DATABASE_URL`.
7. Production OCI container build from `service/Dockerfile`.

### Godot / Web

1. Exact source checkout.
2. Official Godot 4.7.2 stable + export-template installation.
3. Engine version check.
4. Exact-SHA assertion.
5. Headless editor import/parse.
6. `tests/smoke.gd` against the real main scene.
7. Release export with the `Web` preset.
8. Verification that HTML, WASM and PCK outputs exist.
9. Upload of the complete Web build as a GitHub Actions artifact.

A PR is engineering-green only when both jobs succeed on its exact live HEAD.

## Delivery pipeline

A push to `master` repeats the same service and Godot validation. The Web build is uploaded as the GitHub Pages artifact and the deploy job publishes it through the `github-pages` environment only after both blocking jobs pass.

Repository setup requirement: **Settings → Pages → Source: GitHub Actions**.

The community service is intentionally not auto-deployed by this repository yet. SPEC-007 defines a provider-neutral OCI + PostgreSQL + OIDC deployment contract; selecting and provisioning a production hosting provider is a separate operational decision.

## Local parity

With Node.js 22 and Godot 4.7.2 installed:

```bash
npm --prefix service install
npm --prefix service test

godot --headless --path . --editor --quit
godot --headless --path . --script tests/smoke.gd
mkdir -p build/web
godot --headless --path . --export-release "Web" build/web/index.html
```

To run the PostgreSQL integration test locally, supply `TEST_DATABASE_URL` pointing at an isolated test database.

## Files

- `.github/workflows/godot-ci.yml` — CI/CD orchestration.
- `service/Dockerfile` — production community-service image.
- `service/migrations/001_init.sql` — shared PostgreSQL schema.
- `export_presets.cfg` — reproducible Web export.
- `tests/smoke.gd` — runtime smoke gate.
- `build/web` — generated output; never committed.

## Human validation

Human visual/device testing is intentionally asynchronous and non-blocking. It is not part of the default PR gate contract.

Automated CI remains the blocking engineering gate. Device/browser observations are captured separately using `docs/HUMAN-TESTS.md` and converted into persistent follow-up work.

A missing human test result must not, by itself, leave SIGA in `WATCH` or prevent a validated PR from becoming Ready for Review.
