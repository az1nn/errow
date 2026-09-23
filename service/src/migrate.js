import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import pg from "pg";

const { Pool } = pg;
const databaseUrl = process.env.ERROW_DATABASE_URL;
if (!databaseUrl) throw new Error("ERROW_DATABASE_URL is required for migrations.");

const migrationUrl = new URL("../migrations/001_init.sql", import.meta.url);
const sql = await readFile(fileURLToPath(migrationUrl), "utf8");
const pool = new Pool({ connectionString: databaseUrl, ssl: sslConfig() });
try {
  await pool.query(sql);
  console.log("Applied community database migration 001_init.sql");
} finally {
  await pool.end();
}

function sslConfig() {
  return process.env.ERROW_DATABASE_SSL === "disable" ? false : undefined;
}
