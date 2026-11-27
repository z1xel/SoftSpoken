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

## Remaining phases

- DEV2: private account/character tables with the same AceDB defaults and namespaces.
- DEV3: explicit-table canonical geography initialization and safe DEV entry.
- DEV4: pre-start in-game commands and DEV diagnostics.
- DEV5: audit persistent globals and indirect aliases, including logout.
- DEV6: session isolation, reload and ordinary migration regression tests.
- DEV7: real Octo login/reload/logout and semantic comparison of existing
  SavedVariables; use a backup of WTF. The existing TOC remains unchanged.

A DEV session must not imply native audio or other ClassicAPI features are
available. The temporary session flag is never persisted.
