import { createServer } from "node:http";
import { resolve } from "node:path";
import { createApp } from "./app.js";
import { createOidcAuthenticator, createStaticAuthenticator, parseAuthTokens } from "./auth.js";
import { PostgresStore } from "./postgres-store.js";
import { JsonFileStore } from "./store.js";

const port = Number(process.env.PORT ?? 8787);
const host = process.env.HOST ?? "0.0.0.0";
const allowedOrigin = process.env.ERROW_ALLOWED_ORIGIN ?? "*";

const store = await createStore();
await store.init();
const authenticateRequest = createAuthenticator();

const server = createServer(createApp({ store, authenticateRequest, allowedOrigin }));
server.listen(port, host, () => {
  console.log(`Errow community service listening on http://${host}:${port}`);
});

async function createStore() {
  const databaseUrl = process.env.ERROW_DATABASE_URL;
  if (!databaseUrl) {
    const dataFile = resolve(process.env.ERROW_DATA_FILE ?? "service/.data/community.json");
    return new JsonFileStore(dataFile);
  }

  const pg = await import("pg");
  const pool = new pg.default.Pool({
    connectionString: databaseUrl,
    ssl: process.env.ERROW_DATABASE_SSL === "disable" ? false : undefined,
    max: Number(process.env.ERROW_DATABASE_POOL_MAX ?? 10),
  });
  return new PostgresStore(pool);
}

function createAuthenticator() {
  const mode = process.env.ERROW_AUTH_MODE ?? (process.env.ERROW_OIDC_ISSUER ? "oidc" : "static");
  if (mode === "oidc") {
    return createOidcAuthenticator({
      issuer: process.env.ERROW_OIDC_ISSUER,
      audience: process.env.ERROW_OIDC_AUDIENCE,
      jwksUrl: process.env.ERROW_OIDC_JWKS_URL,
    });
  }
  if (mode !== "static") throw new Error(`Unsupported ERROW_AUTH_MODE: ${mode}`);
  return createStaticAuthenticator(parseAuthTokens(process.env.ERROW_AUTH_TOKENS ?? "{}"));
}
