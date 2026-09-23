import { createServer } from "node:http";
import { resolve } from "node:path";
import { createApp, parseAuthTokens } from "./app.js";
import { JsonFileStore } from "./store.js";

const port = Number(process.env.PORT ?? 8787);
const host = process.env.HOST ?? "0.0.0.0";
const dataFile = resolve(process.env.ERROW_DATA_FILE ?? "service/.data/community.json");
const allowedOrigin = process.env.ERROW_ALLOWED_ORIGIN ?? "*";
const authTokens = parseAuthTokens(process.env.ERROW_AUTH_TOKENS ?? "{}");

const store = new JsonFileStore(dataFile);
await store.init();

const server = createServer(createApp({ store, authTokens, allowedOrigin }));
server.listen(port, host, () => {
  console.log(`Errow community service listening on http://${host}:${port}`);
});
