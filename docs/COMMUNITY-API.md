# Community API contract v1

This document defines the HTTP boundary expected by Errow's Godot client.

## Base URL

Configured through the Godot project setting:

`errow/community_api_base_url`

Production Web deployments require HTTPS.

## Authentication

Anonymous discovery is supported by the current service.

Authenticated operations use:

`Authorization: Bearer <token>`

Local development may map opaque tokens to creator IDs through `ERROW_AUTH_TOKENS`.

The production profile validates RS256 JWTs from a configured external OIDC issuer. The token `sub` becomes the canonical creator ID after issuer, audience, signature, expiry and not-before validation. Identity-token issuance remains the responsibility of the configured identity provider; tokens are never persisted inside level data.

## GET /v1/levels?feed={feed}

Supported feed values:

- new
- popular
- trending
- curated

Response:

```json
{
  "levels": [
    {
      "public_id": "ERROW-AB12CD",
      "revision": 1,
      "creator_id": "user-123",
      "published_at": 1790123456,
      "stats": {
        "plays": 120,
        "likes": 44
      },
      "level": {
        "schema_version": 1,
        "name": "Cross Current",
        "subtitle": "Open the lane before the center.",
        "board_size": 5,
        "arrows": [
          [0, 2, "L"],
          [2, 2, "U"]
        ]
      }
    }
  ]
}
```

The client discards entries that fail schema or solvability checks.

## GET /v1/levels/{public_id}/revisions/{revision}

Returns:

```json
{
  "entry": {
    "public_id": "ERROW-AB12CD",
    "revision": 1,
    "creator_id": "user-123",
    "published_at": 1790123456,
    "stats": {
      "plays": 120,
      "likes": 44
    },
    "level": {
      "schema_version": 1,
      "name": "Cross Current",
      "subtitle": "Open the lane before the center.",
      "board_size": 5,
      "arrows": [
        [0, 2, "L"],
        [2, 2, "U"]
      ]
    }
  }
}
```

Published revisions are immutable.

## POST /v1/levels

Request:

```json
{
  "schema_version": 1,
  "client_level_id": "local-123",
  "level": {
    "schema_version": 1,
    "id": "local-123",
    "source": "player",
    "name": "Cross Current",
    "subtitle": "Open the lane before the center.",
    "board_size": 5,
    "arrows": [
      [0, 2, "L"],
      [2, 2, "U"]
    ]
  }
}
```

The server MUST NOT trust client validation.

Before publication it repeats the structural and solvability invariants, assigns a canonical public ID and creates an immutable positive revision. In the PostgreSQL profile, publication of a creator/client-level stream is transactional and serializes revision allocation.

Response uses the same `entry` envelope as the download endpoint.

## Error shape

Recommended error response:

```json
{
  "error": {
    "code": "invalid_level",
    "message": "Level is deadlocked."
  }
}
```

The current client treats non-2xx responses as request failures and does not ingest their body as level data.

## Data ownership boundaries

Level schema:

- puzzle geometry;
- title/subtitle;
- schema version.

Community service metadata:

- public ID;
- revision;
- creator identity;
- publication time;
- play counts;
- likes;
- reports;
- takedown state;
- curation state.

Never store executable Godot content in community submissions.
