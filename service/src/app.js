import { createStaticAuthenticator } from "./auth.js";
import { isSolvable, sanitizeLevel, validateLevel } from "./level-rules.js";

const FEEDS = new Set(["new", "popular", "trending", "curated"]);
const MAX_BODY_BYTES = 64 * 1024;

export function createApp({ store, authenticateRequest, authTokens = new Map(), allowedOrigin = "*" }) {
  const authenticate = authenticateRequest ?? createStaticAuthenticator(authTokens);

  return async function handler(req, res) {
    applyCors(res, allowedOrigin);

    if (req.method === "OPTIONS") {
      res.writeHead(204);
      return res.end();
    }

    try {
      const url = new URL(req.url, "http://localhost");
      if (req.method === "GET" && url.pathname === "/healthz") {
        return json(res, 200, { ok: true });
      }

      if (req.method === "GET" && url.pathname === "/v1/levels") {
        const feed = url.searchParams.get("feed") ?? "new";
        if (!FEEDS.has(feed)) return error(res, 400, "invalid_feed", "Unsupported feed.");
        return json(res, 200, { levels: await store.listFeed(feed) });
      }

      const revisionMatch = url.pathname.match(/^\/v1\/levels\/([A-Za-z0-9-]+)\/revisions\/(\d+)$/);
      if (req.method === "GET" && revisionMatch) {
        const entry = await store.getRevision(revisionMatch[1], Number(revisionMatch[2]));
        if (!entry) return error(res, 404, "not_found", "Published revision not found.");
        return json(res, 200, { entry });
      }

      if (req.method === "POST" && url.pathname === "/v1/levels") {
        const creatorId = await authenticate(req);
        if (!creatorId) return error(res, 401, "unauthorized", "A valid bearer token is required.");

        const body = await readJson(req);
        if (Number(body.schema_version) !== 1) {
          return error(res, 400, "invalid_level", "Unsupported publication schema.");
        }
        if (typeof body.client_level_id !== "string" || !/^[A-Za-z0-9._:-]{1,80}$/.test(body.client_level_id)) {
          return error(res, 400, "invalid_level", "client_level_id must contain 1-80 safe characters.");
        }

        const validationError = validateLevel(body.level);
        if (validationError) return error(res, 400, "invalid_level", validationError);
        if (!isSolvable(body.level)) return error(res, 400, "invalid_level", "Level is deadlocked.");

        const entry = await store.publish({
          creatorId,
          clientLevelId: body.client_level_id,
          level: sanitizeLevel(body.level),
        });
        return json(res, 201, { entry });
      }

      return error(res, 404, "not_found", "Route not found.");
    } catch (cause) {
      if (cause?.code === "invalid_json") return error(res, 400, "invalid_json", "Request body must be valid JSON.");
      if (cause?.code === "body_too_large") return error(res, 413, "body_too_large", "Request body is too large.");
      console.error(cause);
      return error(res, 500, "internal_error", "Unexpected service error.");
    }
  };
}

async function readJson(req) {
  let total = 0;
  const chunks = [];
  for await (const chunk of req) {
    total += chunk.length;
    if (total > MAX_BODY_BYTES) {
      const error = new Error("body_too_large");
      error.code = "body_too_large";
      throw error;
    }
    chunks.push(chunk);
  }
  try {
    return JSON.parse(Buffer.concat(chunks).toString("utf8") || "{}");
  } catch {
    const error = new Error("invalid_json");
    error.code = "invalid_json";
    throw error;
  }
}

function applyCors(res, origin) {
  res.setHeader("Access-Control-Allow-Origin", origin);
  res.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type");
  res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
  res.setHeader("Vary", "Origin");
}

function error(res, status, code, message) {
  return json(res, status, { error: { code, message } });
}

function json(res, status, body) {
  const encoded = JSON.stringify(body);
  res.writeHead(status, {
    "Content-Type": "application/json; charset=utf-8",
    "Content-Length": Buffer.byteLength(encoded),
  });
  res.end(encoded);
}
