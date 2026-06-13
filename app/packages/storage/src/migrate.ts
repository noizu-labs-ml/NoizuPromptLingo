import { readFileSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import pg from "pg";
import { config } from "dotenv";

const { Client } = pg;

config({ path: "../../.env.development" });

const __dirname = dirname(fileURLToPath(import.meta.url));
const migrationsDir = join(__dirname, "..", "migrations");

async function main() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL,
  });
  await client.connect();

  // Create migrations tracking table
  await client.query(`
    CREATE TABLE IF NOT EXISTS _migrations (
      name TEXT PRIMARY KEY,
      applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    )
  `);

  const applied = await client.query("SELECT name FROM _migrations ORDER BY name");
  const appliedSet = new Set(applied.rows.map((r: any) => r.name));

  const files = readdirSync(migrationsDir)
    .filter((f) => f.endsWith(".sql"))
    .sort();

  for (const file of files) {
    if (appliedSet.has(file)) {
      console.log(`  skip: ${file} (already applied)`);
      continue;
    }
    const sql = readFileSync(join(migrationsDir, file), "utf-8");
    console.log(`  apply: ${file}`);
    await client.query(sql);
    await client.query("INSERT INTO _migrations (name) VALUES ($1)", [file]);
  }

  console.log("Migrations complete.");
  await client.end();
}

main().catch(console.error);
