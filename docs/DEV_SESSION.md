# DEV session mode — no TOC changes

Goal: an explicitly activated in-game session with all addon state held in
private Lua tables, without the ClassicAPI SavedVariables importer. Existing
declared SavedVariables must never be borrowed, cleared or changed by DEV.
The client still controls serialization of the existing TOC globals; this
does not promise zero filesystem writes or byte-identical files.

## DEV1 — startup coordinator

The session-local StartupController exposes GetState() and Start(mode).
Normal login attempts startup once. States are pending, blocked, initializing,
running and failed; the future dev state is reserved for a successful temporary
session. GetState returns the state and a reason when applicable. Only pending
or pre-controller blocked states may enter initialization after PLAYER_LOGIN.
Upgrade conflicts and migration failures are blocked; a failed Core or later
controller is terminal for this session, requiring reload. Reentrant attempts,
attempts to switch a running session, and pre-login requests are rejected.
A pre-controller block can be retried explicitly in normal mode; the guard
and migration run again. The login event never retries automatically.

DEV activation deliberately fails closed with dev-storage-unavailable until
the isolated backend and canonical character history are ready. No slash
commands, skipped migrations or alternative database writes are introduced
in DEV1. Existing normal initialization order and failure isolation are
retained; startupComplete remains separate from migration completion.

## DEV2 — temporary storage backend

Persistence:Initialize(coreDefaults, storiesProfileDefaults, mode) accepts
normal (default) or dev. Both use the real AceDB and the same three namespaces,
defaults and character-table initialization. DEV allocates a private account
table and a fresh character table using the existing detached canonical
LocationHistory:Transform({}) operation; it never calls the global-writing
Upgrade method or the importer. No legacy data is copied or consulted. The
selected mode is session-local; explicit backend switches after initialization
are rejected, while ordinary repeat initialization returns the existing root.
DEV1 initially rejected DEV until DEV3 wired safe entry.
Tests exercise the real registry, AceDB, both empty and populated saved
globals, temporary history, profile operations and AceDB logout cleanup.

## DEV3 — safe explicit startup

StartupController:Start("dev") is now available after PLAYER_LOGIN in a
pending or blocked session. The installation guard still runs. Only normal
mode invokes RecoverLegacy; the coordinator passes the explicit mode through
Core to Persistence. No persistent history is upgraded in DEV. Success enters
the dev state; partial controller failures require reload. No runtime
database switch is allowed. A session-local world-entry observer lets late
startup schedule Stories' deferred pack loading and arm Places' initial
location stabilization even if PLAYER_ENTERING_WORLD already fired.
DEV skips automatic Compendium keybinding seeding because that writes to
WoW's binding set. Other native/client effects need DEV5 review. The existing
slash command was not yet routed to DEV at DEV3. Internal testing can
call SpokenEnv.StartupController:Start("dev") after a blocked login; live
client validation remains outstanding.

## DEV4 — in-game activation

Startup owns /softspoken before PLAYER_LOGIN, so a failed migration cannot
hide the entry point. /softspoken dev starts an isolated session after a
pre-controller block, prints a clear temporary-state notice, and is
idempotent. A running normal session cannot be switched to DEV; no in-place
database rebinding is supported. /softspoken undev invokes ReloadUI only in
DEV (including partial failure with an initialized DEV backend), discards
temporary state through the normal reload lifecycle and attempts normal
startup on the next login. /softspoken status reports startup and storage
state. The bare command still opens settings in running sessions; blocked
sessions receive a helpful hint. Existing diagnostics include the same
startup/storage status. Core retains /compendium and does not replace the
startup command. No state flag or setting is written to disk. DEV3's
integrated test fixture now supplies the missing profile refresh collaborators.

## Remaining phases

- DEV5: audit persistent globals and indirect aliases, including logout.
- DEV6: session isolation, reload and ordinary migration regression tests.
- DEV7: real Octo login/reload/logout and semantic comparison of existing
  SavedVariables; use a backup of WTF. The existing TOC remains unchanged.

A DEV session must not imply native audio or other ClassicAPI features are
available. The temporary session flag is never persisted.
