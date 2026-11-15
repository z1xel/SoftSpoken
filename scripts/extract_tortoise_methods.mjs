#!/usr/bin/env node
// Rebuild only Tortoise's quest_template from its raw SQL and world migrations,
// using the viewer's already-reviewed staging parser. Export Method separately:
// the published simplified viewer SQLite intentionally drops that column.
import { writeFileSync, readFileSync } from "node:fs";
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
  // Which quest text fields this actual Turtle world SQL MIGRATION history
  // changed from the pinned Turtle base dump. Emit IDs/field names only.
  // Comparing with cMaNGOS then shows whether those changes remain visible
  // against Vanilla. Neither source quest dialogue is written to a report.
  const { parseColumns, iterRows, NULL } = await import(
    pathToFileURL(resolve(viewer, "sqldump.mjs")).href);
  const baseSql = readFileSync(resolve(sql, "tw_world_quest_template.sql"), "utf8");
  const baseCols = parseColumns(baseSql);
  const compare = ["Title", "Details", "Objectives", "RequestItemsText", "OfferRewardText"];
  const idx = Object.fromEntries(["entry", ...compare].map(k => [k, baseCols.indexOf(k)]));
  for (const [k, value] of Object.entries(idx))
    if (value === -1) throw new Error("Turtle base schema missing " + k);
  const base = new Map();
  for (const row of iterRows(baseSql, "quest_template")) {
    const id = Number(row[idx.entry]);
    if (!id) continue;
    base.set(id, Object.fromEntries(compare.map(k =>
      [k, row[idx[k]] === NULL ? null : row[idx[k]]])));
  }
  const simplified = v => String(v == null ? "" : v)
    .replace(/\r\n?/g, "\n").replace(/\s+/g, " ").trim();
  const changes = [["entry", "source_quest_introduced_by_migration", "modified_text_fields"].join(",")];
  let touched = 0, addedQuest = 0, fieldChanged = 0;
  const migrated = db.prepare(
    "SELECT entry, Title, Details, Objectives, RequestItemsText, OfferRewardText FROM stg_quest_template").all();
  for (const row of migrated) {
    const initial = base.get(Number(row.entry));
    const fields = initial
      ? compare.filter(k => simplified(row[k]) !== simplified(initial[k]))
      : compare.slice();
    if (!fields.length && initial) continue;
    touched++;
    if (!initial) addedQuest++; else fieldChanged++;
    changes.push([row.entry, initial ? 0 : 1, fields.join(";")].join(","));
  }
  writeFileSync(resolve(root, ".audit-migration-text-changes.csv"), changes.join("\n") + "\n");
  console.log("Tortoise SQL migrations: " + touched + " text-affected quest IDs (" +
    addedQuest + " new, " + fieldChanged + " text-edited); fields only, no dialogue copied.");
  console.log("Staged " + rows.length + " Method records with migrations " +
              JSON.stringify(staged.stats));
} finally {
  db.close();
}
