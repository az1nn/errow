# Human Test Protocol — Async

Human testing in Errow is asynchronous evidence collection, not a blocking development gate.

Automated CI is the engineering gate for pull requests. Human testing supplements CI with device, browser, visual and interaction observations that are difficult or inefficient to automate.

## Policy

- Human testing does **not** block a branch, pull request, merge preparation or the next development workstream by default.
- Do not leave a workstream in `WATCH` only because a person has not yet tested the UI.
- Do not require visual approval before marking an otherwise validated PR Ready for Review.
- Human findings are recorded as follow-up work and prioritized independently.
- A human test can become blocking only when the user explicitly declares a specific release/review gate for that test.
- Automated failures remain blocking engineering failures and must be fixed in the active workstream.

## Async test packet

Anyone testing a build should use the Web artifact produced by the exact commit under test or a deployed build that identifies the same commit.

Record:

- commit SHA;
- artifact/deploy identifier;
- device and OS;
- browser and version;
- viewport/orientation;
- date;
- result: PASS / ISSUE;
- short evidence: screenshot, screen recording or concise reproduction steps when useful.

## MVP human checks

### Startup

- Game opens without a blank or broken screen.
- ERROW title and instructions are readable.
- Level 1 appears without manual recovery/reload.

### Responsive layout

Test at least one phone-sized viewport and one desktop-sized viewport.

Observe:

- board remains fully reachable;
- controls do not overlap;
- labels do not clip;
- completion modal fits the viewport;
- portrait mobile layout remains usable.

### Arrow readability

- Up/right/down/left glyphs are visually distinguishable.
- Arrow contrast is sufficient against its button.
- Disabled/pressed feedback does not make direction ambiguous.

### Interaction

- Touch/click reliably activates the intended arrow.
- A blocked arrow remains on the board and gives visible feedback.
- A clear arrow disappears.
- Restart restores the current level.
- Next level advances correctly.
- Final completion returns to level 1 as designed.

### Gameplay feel

Observe rather than gate:

- tap targets feel large enough;
- blocked feedback is understandable;
- board spacing feels intentional;
- successful actions feel responsive;
- level progression is understandable without extra explanation.

## Reporting findings

Human findings must not be hidden in chat-only state.

Use one of these repository-persistent forms:

1. GitHub issue for a discrete defect or improvement.
2. PR comment when the finding directly concerns the active PR.
3. Follow-up spec/task when several observations belong to one UX iteration.

A useful finding contains:

```text
SHA:
BUILD / ARTIFACT:
DEVICE / BROWSER:
RESULT:
OBSERVED:
EXPECTED:
REPRO:
EVIDENCE:
SEVERITY:
```

Suggested severity:

- P0 — unusable/crash/data-loss/security class defect.
- P1 — core gameplay cannot be completed on a meaningful target.
- P2 — degraded UX with a workaround.
- P3 — polish, preference or minor visual issue.

Severity helps prioritize follow-up work; it does not silently create a gate. A blocking decision must be explicit.

## SIGA behavior

On standalone `Siga`:

- reconcile automated gates and active work first;
- consume any human-test findings already persisted;
- fix an active defect in-place when it belongs to the current workstream;
- otherwise record/schedule it as follow-up;
- never remain `WATCH` solely because human testing has not happened;
- advance when automated work is complete and there is no other active blocker.

Human testing may happen before, during or after subsequent development.
