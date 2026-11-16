#!/usr/bin/env node
/**
 * One-command local import into SoftSpoken_Stories/Data/TurtleQuestText.lua.
 * No companion addon; preserves the original Spoken corpus.
 *
 * Requires Node.js 18+ and Python 3.
 * Usage: node scripts/import_tortoise_quest_dialogue.mjs
 *        node scripts/import_tortoise_quest_dialogue.mjs --source-sqlite PATH
 */
import { createHash } from "node:crypto";
import { execFileSync } from "node:child_process";
import { copyFileSync, existsSync, mkdtempSync, readFileSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { brotliDecompressSync } from "node:zlib";

const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const OUTPUT = join(ROOT, "SoftSpoken_Stories", "Data", "TurtleQuestText.lua");
const REF = "567ce23c73087e9b67fd2d4732c171d751e54bba";
const BLOB_SHA = "7b126fce5260502fa40f9f6b67190f920e60a0f6";
const SOURCE_URL = "https://raw.githubusercontent.com/Xian55/tortoise-db-viewer/" +
    REF + "/data/tortoise.sqlite.br";

function parseArgs(args) {
    if (args.length === 1 && (args[0] === "--help" || args[0] === "-h")) {
        console.log("node scripts/import_tortoise_quest_dialogue.mjs [--touched-only] [--source-sqlite PATH]");
        console.log("--touched-only verifies 13 restored + 207 repaired/missing + 13 Tier 3 + 3 title-aliased 41797 stages");
        console.log("Default regenerates 2369 source-title-matched quests plus four verified addition batches.");
        return null;
    }
    const touchedCount = args.filter(x => x === "--touched-only").length;
    if (touchedCount > 1) throw new Error("--touched-only supplied more than once");
    const touchedOnly = touchedCount === 1;
    const remaining = args.filter(x => x !== "--touched-only");
    if (remaining.length === 0) return { touchedOnly };
    if (remaining.length !== 2 || remaining[0] !== "--source-sqlite")
        throw new Error("Expected [--touched-only] [--source-sqlite PATH]");
    return { db: resolve(remaining[1]), touchedOnly };
}

async function getDb(input, temp) {
    if (input.db) {
        if (!existsSync(input.db)) throw new Error("Missing local SQLite: " + input.db);
        return input.db;
    }
    const response = await fetch(SOURCE_URL, { signal: AbortSignal.timeout(120000) });
    if (!response.ok) throw new Error("Pinned SQLite download failed: HTTP " + response.status);
    const compressed = Buffer.from(await response.arrayBuffer());
    const sha = createHash("sha1")
        .update(Buffer.from("blob " + compressed.length + "\0"))
        .update(compressed)
        .digest("hex");
    if (sha !== BLOB_SHA) throw new Error("Pinned source checksum mismatch: " + sha);
    const content = brotliDecompressSync(compressed);
    if (content.subarray(0,16).toString("latin1") !== "SQLite format 3\0")
        throw new Error("Source is not a SQLite database");
    const db = join(temp, "tortoise.sqlite");
    writeFileSync(db, content);
    console.log("Source verified: Tortoise viewer CDN commit " + REF.slice(0,12));
    return db;
}

function runPython(args) {
    const candidates = process.platform === "win32" ? [["py", "-3"], ["python", null]]
        : [["python3", null], ["python", null]];
    for (const [exe, flag] of candidates) {
        try {
            execFileSync(exe, [...(flag ? [flag] : []), ...args], {
                cwd: ROOT, stdio: "inherit"
            });
            return;
        } catch (err) {
            if (err.code === "ENOENT") continue;
            throw new Error("Python importer failed (" + exe + "): " + err.message);
        }
    }
    throw new Error("Python 3 not available");
}

async function main() {
    const input = parseArgs(process.argv.slice(2));
    if (!input) return;
    const temp = mkdtempSync(join(tmpdir(), "softspoken-quest-text-"));
    try {
        const db = await getDb(input, temp);
        if (input.touchedOnly) {
            // Stage all writes into a TEMPORARY copy. No partial local
            // overwrite if any later SHA or collision guard fails.
            if (!existsSync(OUTPUT)) throw new Error("Existing TurtleQuestText.lua is missing");
            const staged = join(temp, "TurtleQuestText.lua");
            copyFileSync(OUTPUT, staged);
            runPython([
                join(ROOT, "scripts", "import_turtle_touched_text.py"),
                "--db", db,
                "--manifest", join(ROOT, "docs", "audits", "turtle_touched_text_coverage",
                                   "first_batch_verified_stages.csv"),
                "--destination", staged,
                "--write", "--local-only"
            ]);
            runPython([
                join(ROOT, "scripts", "import_turtle_missing_stages.py"),
                "--db", db,
                "--destination", staged,
                "--write"
            ]);
            runPython([
                join(ROOT, "scripts", "import_turtle_tier3_completions.py"),
                "--db", db,
                "--destination", staged,
                "--write"
            ]);
            runPython([
                join(ROOT, "scripts", "import_turtle_approved_alias.py"),
                "--db", db,
                "--destination", staged,
                "--write"
            ]);
            renameSync(staged, OUTPUT);
            console.log("Applied 13 restored + 207 missing/repaired + 13 Tier 3 + 3 stages of quest 41797 atomically.");
            return;
        }
        const staged = join(temp, "TurtleQuestText.lua");
        const report = join(temp, "report");
        runPython([
            join(ROOT, "scripts", "prepare_tortoise_quest_overlay.py"),
            "--db", db,
            "--manifest", join(ROOT, "docs", "turtle_exclusive_import.csv"),
            "--out", report,
            "--source-ref", "Xian55/tortoise-db-viewer cdn@" + REF,
            "--emit-text", staged,
            "--local-only"
        ]);
        const summary = JSON.parse(readFileSync(join(report, "summary.json"), "utf8"));
        if (summary.total_targets !== 2377 || summary.eligible !== 2369 ||
            summary.generated?.quest_rows_written !== 2369 || summary.held.length !== 8)
            throw new Error("Unexpected coverage; refusing to overwrite addon Lua file");
        // Compose the strictly audited old/shared-ID batch into the SAME
        // staged Lua table. The Python importer verifies all 13 stage hashes
        // against this pinned SQLite, and refuses overlapping existing IDs.
        runPython([
            join(ROOT, "scripts", "import_turtle_touched_text.py"),
            "--db", db,
            "--manifest", join(ROOT, "docs", "audits", "turtle_touched_text_coverage",
                               "first_batch_verified_stages.csv"),
            "--destination", staged,
            "--write", "--local-only"
        ]);
        // This second stage batch is stage-specific and never changes the
        // previously imported 13 restored stages or existing high-ID text.
        runPython([
            join(ROOT, "scripts", "import_turtle_missing_stages.py"),
            "--db", db,
            "--destination", staged,
            "--write"
        ]);
        runPython([
            join(ROOT, "scripts", "import_turtle_tier3_completions.py"),
            "--db", db,
            "--destination", staged,
            "--write"
        ]);
        runPython([
            join(ROOT, "scripts", "import_turtle_approved_alias.py"),
            "--db", db,
            "--destination", staged,
            "--write"
        ]);
        const lua = readFileSync(staged, "utf8");
        if (!lua.includes("SSCTurtleQuestText[40001]"))
            throw new Error("Staged Lua is missing a known imported quest");
        if (!lua.includes("SSCTurtleQuestText[820].accept =") ||
            !lua.includes("SSCTurtleQuestText[3111].accept =") ||
            !lua.includes("SSCTurtleQuestText[3580].complete =") ||
            !lua.includes("SSCTurtleQuestText[38].progress =") ||
            !lua.includes("-- END Turtle-touched missing 207 dialogue stages") ||
            !lua.includes("-- END verified Tier 3 completion dialogue (13 quest stages)") ||
            !lua.includes("-- END verified Turtle title alias quest 41797"))
            throw new Error("Staged Lua is missing the verified restored quest batch");
        // The target is overwritten only after a complete, checked export.
        renameSync(staged, OUTPUT);
        console.log("\nImported " + summary.generated.quest_rows_written + " quests directly into:");
        console.log(OUTPUT);
        console.log("Exclusive quest dialogue stages: " + JSON.stringify(summary.generated.stages_written));
        console.log("Additional dialogue: 13 restored + 207 missing/repaired + 13 Tier 3 + 3 approved alias stages; 1 new exclusive ID.");
        console.log("Held for later source verification: " + summary.held.join(", "));
        console.log("No companion addon was created. Preserve this local file when updating the repo.");
    } finally {
        rmSync(temp, { recursive: true, force: true });
    }
}

main().catch(err => { console.error(err.stack || String(err)); process.exitCode = 1; });
