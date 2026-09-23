import test from "node:test";
import assert from "node:assert/strict";
import { generateKeyPairSync, sign } from "node:crypto";
import { createOidcAuthenticator } from "../src/auth.js";

const { publicKey, privateKey } = generateKeyPairSync("rsa", { modulusLength: 2048 });
const jwk = publicKey.export({ format: "jwk" });
jwk.kid = "test-key";
jwk.use = "sig";
jwk.alg = "RS256";

const issuer = "https://identity.example.test/";
const audience = "errow-community";
const now = 1_800_000_000_000;

function requestWith(token) {
  return { headers: { authorization: `Bearer ${token}` } };
}

function jwt(payload, header = { alg: "RS256", typ: "JWT", kid: "test-key" }) {
  const encodedHeader = Buffer.from(JSON.stringify(header)).toString("base64url");
  const encodedPayload = Buffer.from(JSON.stringify(payload)).toString("base64url");
  const input = `${encodedHeader}.${encodedPayload}`;
  const signature = sign("RSA-SHA256", Buffer.from(input), privateKey).toString("base64url");
  return `${input}.${signature}`;
}

function authenticator() {
  return createOidcAuthenticator({
    issuer,
    audience,
    jwksUrl: `${issuer}.well-known/jwks.json`,
    clock: () => now,
    fetchImpl: async () => ({ ok: true, json: async () => ({ keys: [jwk] }) }),
  });
}

test("accepts a valid RS256 OIDC access token and returns sub", async () => {
  const token = jwt({ iss: issuer, aud: audience, sub: "user-oidc", exp: now / 1000 + 60 });
  assert.equal(await authenticator()(requestWith(token)), "user-oidc");
});

test("rejects wrong audience, expired token and unsupported algorithm", async () => {
  const auth = authenticator();
  const wrongAudience = jwt({ iss: issuer, aud: "other", sub: "user", exp: now / 1000 + 60 });
  assert.equal(await auth(requestWith(wrongAudience)), null);

  const expired = jwt({ iss: issuer, aud: audience, sub: "user", exp: now / 1000 - 31 });
  assert.equal(await auth(requestWith(expired)), null);

  const unsupported = jwt(
    { iss: issuer, aud: audience, sub: "user", exp: now / 1000 + 60 },
    { alg: "HS256", typ: "JWT", kid: "test-key" },
  );
  assert.equal(await auth(requestWith(unsupported)), null);

  const valid = jwt({ iss: issuer, aud: audience, sub: "user", exp: now / 1000 + 60 });
  const pieces = valid.split(".");
  pieces[2] = Buffer.from("tampered-signature").toString("base64url");
  assert.equal(await auth(requestWith(pieces.join("."))), null);
});
