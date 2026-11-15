#!/usr/bin/env node
// Rebuild only Tortoise's quest_template from its raw SQL and world migrations,
// using the viewer's already-reviewed staging parser. Export Method separately:
// the published simplified viewer SQLite intentionally drops that column.
import { writeFileSync } from "node:fs";
import { resolve } from "node:path";
import { pathToFileURL } from "node:url";

const root = resolve(process.cwd());
const viewer = resolve(root, ".audit-viewer", "scripts", "lib");
const { openDatabase } = await import(pathToFileURL(resolve(viewer, "sqlite.mjs")).href);
const { buildStaging } = await import(pathToFileURL(resolve(viewer, "staging.mjs")).href);
const db = await openDatabase(":memory:");
try {
  const sql = resolve(root, ".audit-world", "sql", "base");
  const updates = resolve(root, ".audit-world", "sql", "database_updates");
  const staged = buildStaging(db, sql, updates, [
    { table: "quest_template", file: "tw_world_quest_template.sql", pk: "entry" }
  ]);
  if (!staged.has("quest_template")) throw new Error("Missing raw quest_template SQL");
  const cols = staged.columns("quest_template");
  for (const c of ["entry", "Method", "Title", "ZoneOrSort"])
    if (!cols.includes(c)) throw new Error("Source missing column " + c);
  const fields = ["entry", "method", "title", "zone"];
  const quote = v => '"' + String(v == null ? "" : v).replace(/"/g, '""') + '"';
  const lines = [fields.join(",")];
  const rows = db.prepare("SELECT entry, Method, Title, ZoneOrSort FROM stg_quest_template").all();
  for (const row of rows) {
    lines.push([row.entry, row.Method, row.Title, row.ZoneOrSort].map(quote).join(","));
  }
  writeFileSync(resolve(root, ".audit-methods.csv"), lines.join("\n") + "\n");
  writeFileSync(resolve(root, ".audit-methods-meta.json"), JSON.stringify({
    count: rows.length,
    migration_stats: staged.stats,
    note: "Source raw Tortoise quest_template with world migrations, for comparison against pinned viewer snapshot."
  }, null, 2));
  console.log("Staged " + rows.length + " Method records with migrations " +
              JSON.stringify(staged.stats));
} finally {
  db.close();
}
