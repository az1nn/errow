import { createPublicKey, verify as verifySignature } from "node:crypto";

const DEFAULT_CLOCK_SKEW_SECONDS = 30;
const DEFAULT_JWKS_TTL_MS = 5 * 60 * 1000;

export function createStaticAuthenticator(authTokens = new Map()) {
  return async function authenticateStatic(req) {
    const token = bearerToken(req);
    return token ? authTokens.get(token) ?? null : null;
  };
}

export function createOidcAuthenticator({ issuer, audience, jwksUrl, fetchImpl = fetch, clock = () => Date.now(), jwksTtlMs = DEFAULT_JWKS_TTL_MS }) {
  if (!issuer || !audience || !jwksUrl) {
    throw new Error("OIDC issuer, audience and JWKS URL are required.");
  }

  let cache = { expiresAt: 0, keys: new Map() };

  return async function authenticateOidc(req) {
    const token = bearerToken(req);
    if (!token) return null;

    const parts = token.split(".");
    if (parts.length !== 3) return null;

    let header;
    let payload;
    try {
      header = JSON.parse(decodeBase64Url(parts[0]).toString("utf8"));
      payload = JSON.parse(decodeBase64Url(parts[1]).toString("utf8"));
    } catch {
      return null;
    }

    if (header?.alg !== "RS256" || typeof header?.kid !== "string" || !header.kid) return null;
    if (!claimsAreValid(payload, { issuer, audience, nowSeconds: Math.floor(clock() / 1000) })) return null;

    let key = cache.expiresAt > clock() ? cache.keys.get(header.kid) : null;
    if (!key) {
      cache = await loadJwks(jwksUrl, fetchImpl, clock() + jwksTtlMs);
      key = cache.keys.get(header.kid);
      if (!key) return null;
    }

    const signingInput = Buffer.from(`${parts[0]}.${parts[1]}`);
    const signature = decodeBase64Url(parts[2]);
    const verified = verifySignature("RSA-SHA256", signingInput, key, signature);
    return verified ? payload.sub : null;
  };
}

export function parseAuthTokens(raw) {
  if (!raw) return new Map();
  const value = JSON.parse(raw);
  if (!value || typeof value !== "object" || Array.isArray(value)) {
    throw new Error("ERROW_AUTH_TOKENS must be a JSON object.");
  }
  return new Map(Object.entries(value).filter(([token, creatorId]) => token && typeof creatorId === "string" && creatorId));
}

function bearerToken(req) {
  const header = req.headers.authorization ?? "";
  const match = header.match(/^Bearer\s+(.+)$/i);
  return match ? match[1] : null;
}

function claimsAreValid(payload, { issuer, audience, nowSeconds }) {
  if (!payload || typeof payload !== "object") return false;
  if (typeof payload.sub !== "string" || !payload.sub) return false;
  if (payload.iss !== issuer) return false;

  const audiences = Array.isArray(payload.aud) ? payload.aud : [payload.aud];
  if (!audiences.includes(audience)) return false;

  if (!Number.isFinite(payload.exp) || payload.exp < nowSeconds - DEFAULT_CLOCK_SKEW_SECONDS) return false;
  if (payload.nbf != null && (!Number.isFinite(payload.nbf) || payload.nbf > nowSeconds + DEFAULT_CLOCK_SKEW_SECONDS)) return false;
  return true;
}

async function loadJwks(jwksUrl, fetchImpl, expiresAt) {
  const response = await fetchImpl(jwksUrl, { headers: { accept: "application/json" } });
  if (!response.ok) throw new Error(`Unable to load OIDC JWKS: HTTP ${response.status}`);
  const document = await response.json();
  if (!Array.isArray(document?.keys)) throw new Error("OIDC JWKS must contain a keys array.");

  const keys = new Map();
  for (const jwk of document.keys) {
    if (jwk?.kty !== "RSA" || typeof jwk.kid !== "string" || !jwk.kid) continue;
    try {
      keys.set(jwk.kid, createPublicKey({ key: jwk, format: "jwk" }));
    } catch {
      // Ignore unusable keys; a matching valid signing key is required below.
    }
  }
  return { expiresAt, keys };
}

function decodeBase64Url(value) {
  return Buffer.from(value, "base64url");
}
