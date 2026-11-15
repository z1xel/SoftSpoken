#!/usr/bin/env node
/**
 * Local Turtle quest dialogue companion addon installer.
 * Node >=18 and Python 3 required.
 *
 * node scripts/install_tortoise_quest_dialogue.mjs
 * node scripts/install_tortoise_quest_dialogue.mjs --addons-dir path/to/Interface/AddOns
 * node scripts/install_tortoise_quest_dialogue.mjs --source-sqlite path/to/tortoise.sqlite
 */
import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { brotliDecompressSync } from "node:zlib";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const CDN_REF = "567ce23c73087e9b67fd2d4732c171d751e54bba";
const BLOB_SHA = "7b126fce5260502fa40f9f6b67190f920e60a0f6";
const URL = "https://raw.githubusercontent.com/Xian55/tortoise-db-viewer/" +
  CDN_REF + "/data/tortoise.sqlite.br";

function usage() {
  console.log("Usage: node scripts/install_tortoise_quest_dialogue.mjs " +
    "[--addons-dir <Interface/AddOns>] [--source-sqlite <database.sqlite>]\n" +
    "Default: writes local_build/AddOns/SoftSpoken_TurtleQuestText; never commits.");
}
function parseArgs(argv) {
  const out = {};
  for (let i = 0; i < argv.length; i++) {
    const flag = argv[i];
    if (flag === "--help" || flag === "-h") { out.help = true; continue; }
    if (flag !== "--addons-dir" && flag !== "--source-sqlite")
      throw new Error("Unknown argument: " + flag);
    if (!argv[i+1]) throw new Error("Missing value for " + flag);
    out[flag.slice(2)] = resolve(argv[++i]);
  }
  return out;
}
async function getDatabase(args, temp) {
  if (args["source-sqlite"]) return args["source-sqlite"];
  const response = await fetch(URL, { signal: AbortSignal.timeout(90000) });
  if (!response.ok) throw new Error("Snapshot download failed: HTTP " + response.status);
  const compressed = Buffer.from(await response.arrayBuffer());
  const gitHash = createHash("sha1")
    .update(Buffer.from("blob " + compressed.length + "\0"))
    .update(compressed).digest("hex");
  if (gitHash !== BLOB_SHA) throw new Error("Pinned SQLite blob SHA mismatch: " + gitHash);
  const sqlite = brotliDecompressSync(compressed);
  if (sqlite.subarray(0,16).toString("latin1") !== "SQLite format 3\0")
    throw new Error("Decompressed snapshot is not SQLite 3");
  const path = join(temp,"tortoise.sqlite");
  writeFileSync(path, sqlite);
  console.log("Verified pinned SQLite snapshot " + CDN_REF.slice(0,12) +
              " (" + sqlite.length + " bytes)");
  return path;
}
function runPython(script, args) {
  const commands = process.platform === "win32"
    ? [["py","-3"], ["python",null]]
    : [["python3",null], ["python",null]];
  const missing = [];
  for (const [bin, extra] of commands) {
    try {
      execFileSync(bin, [...(extra ? [extra] : []), script, ...args],
                   { cwd: ROOT, stdio: "inherit" });
      return;
    } catch (err) {
      if (err.code === "ENOENT") { missing.push(bin); continue; }
      throw new Error("Importer failed (" + bin + "): " + err.message);
    }
  }
  throw new Error("Python 3 not found. Tried: " + missing.join(", "));
}
async function main() {
  const args = parseArgs(process.argv.slice(2));
  if (args.help) return usage();
  const addOnsDir = args["addons-dir"] || join(ROOT,"local_build","AddOns");
  const pack = join(addOnsDir,"SoftSpoken_TurtleQuestText");
  const temp = mkdtempSync(join(tmpdir(),"softspoken-tortoise-"));
  try {
    const sqlite = await getDatabase(args,temp);
    mkdirSync(pack,{recursive:true});
    writeFileSync(join(pack,"SoftSpoken_TurtleQuestText.toc"),
      "## Interface: 11200\n" +
      "## Title: SoftSpoken - Turtle Quest Text (Local)\n" +
      "## Notes: User-generated Turtle quest dialogue overlay\n" +
      "## Dependencies: SoftSpoken_Stories\n" +
      "TurtleQuestText.lua\n");
    const dest = join(pack,"TurtleQuestText.lua");
    runPython(join(ROOT,"scripts","prepare_tortoise_quest_overlay.py"), [
      "--db",sqlite,"--manifest",join(ROOT,"docs","turtle_exclusive_import.csv"),
      "--out",join(temp,"report"),"--source-ref","cdn@"+CDN_REF,
      "--emit-text",dest,"--local-only",
    ]);
    const summary = JSON.parse(readFileSync(join(temp,"report","summary.json"),"utf8"));
    console.log("\nLocal Turtle dialogue pack created: " + pack);
    console.log("Imported " + summary.generated.quest_rows_written + " quests; " +
      JSON.stringify(summary.generated.stages_written) + " dialogue stages; held " +
      summary.held.length + " source conflicts.");
    console.log("If necessary, copy SoftSpoken_TurtleQuestText into the game's Interface/AddOns.");
    console.log("Do not commit or redistribute the generated dialogue without permission.");
  } finally {
    rmSync(temp,{recursive:true,force:true});
  }
}
main().catch(err=>{console.error(err.stack||String(err));process.exitCode=1;});
