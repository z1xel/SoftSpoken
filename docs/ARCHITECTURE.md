# SoftSpoken architecture (Turtle WoW 1.12)

## One shared audio engine

```text
WoW events / ClassicAPI / SuperWoW
    |                 |                  |
  Zones             Books             Quests / Gossip
  - discovery       - checksums       - quest & NPC IDs
  - lore            - reader pages    - dialogue state
  - autoplay        - playlists       - gossip selection
    |                 |                  |
    +-----------------+------------------+
                      |
          resolve a module-specific clip
                      |
            Spoken:RegisterSource
                      |
            source:Enqueue / PlayNow
                      |
          SoftSpoken/SoundQueue.lua
                      |
               PlaySoundFile
                      |
             shared callbacks
                 /          \
         PlayerFrame     Transcript
```

The core does not read quest, book or zone databases. Each module constructs
the same clip contract (key, path, length, present), and the core owns
priorities, timers, captions, shared controls, notifications and queue order.

## Compendium flow

```text
Zones (Places tab) ---------+
Books (Books tab) ----------+--> SSCCompendium:Register(key, tab)
Quests (Quests tab) --------+        |
                                     v
                         shared Compendium shell
                         tree/list and PagePane.lua
                                     |
                              domain tab content
                                     |
                         module audio playback request
                                     |
                              shared SoundQueue
```

Compendium geometry is now owned by the core. The prior first-tab storage
is consulted lazily to migrate existing width and height into
SpokenSettings.char.Compendium. Filters and discovered/read/quest state remain
owned by each module's saved variables.

Compendium/UI/PagePane.lua owns the shared inset, scroll housing, skin and
exact 1.12 placements. Modules pass their own page factory so Places can keep
its historical singleton while Books/Quests retain independent page and scroll
state.

## Module-specific responsibilities

- **Zones:** map/exploration adapter, visited/heard history, audio registry
  lookup, startup/discovery autoplay and Places tab.
- **Books:** page checksum and index lookup, book read history, voice packs,
  physical-page versus Compendium continuation and Books tab.
- **Quests:** quest and gossip events, ClassicAPI quest state, NPC/voice lookup,
  optional/deferred audio packs and Quests tab.

## Load and compatibility invariants

- 1.12 runs Lua 5.0. Preserve event/arg global fallbacks and legacy widget APIs.
- The feature .toc files hard-depend on SoftSpoken. The core's common Ace/LibStub
  libraries load first; Quests keeps its own AceAddon/AceGUI/config libraries.
- Core internals use SpokenEnv; Quests uses its own VoiceOver environment.
  VoiceOver must not be renamed because shipped voice packs reference it.
- Quests and gossip have separate sources sharing one global queue.
- A physical book plays only the visible page; the Compendium continues pages.
- Shared Compendium UI must not require Zones, Books or Quests to be installed.
- The separate SSZ_Portrait_Template_Test folder is a development fixture, not
  a required runtime dependency.

## In-game regression checklist

1. Core only: queue controls, settings, portrait, captions, minimap.
2. Core + each module separately: play/pause, UI tabs, and missing-pack cases.
3. All modules: global queue priority, source switches, Compendium tab switching.
4. Legacy Compendium width/height: confirm migration after login and reload.
5. Prototype disabled: page art, tabs, scrollbars, resize and frame stacking.
6. Places: visit/discovery history, map selection/highlights and autoplay.
7. Books: in-world page-turn pause; continuous Compendium book playback.
8. Quests: dialogue/gossip, quest history, source playback and deferred packs.
9. Compare geometry against the approved prototype screenshots.


## Shared language and voice-availability updates

- SoftSpoken/Language.lua owns the locale list, client locale lookup,
  voice and fallback ordering, including English defaults for old packs.
- Spoken.Language is additive on the public Spoken API. Books and Quests keep
  their previous public method names as thin adapters and continue to prefer
  the module's saved preferences until the core field is explicitly selected.
- Spoken:SetLanguageChoice("voice"|"fallback", code) updates the core preference
  and broadcasts VOICE_LANGUAGE_CHANGED.
- Spoken:NotifyVoicePacksChanged() broadcasts the existing VOICE_PACKS_LOADED
  event without exposing SpokenEnv internals to feature modules.
- Quests invalidates its Compendium Voiced Only cache after deferred/manual
  audio-pack loads, language changes and quest profile changes.
- Zones play buttons normally use shared AUDIO_CHANGED callbacks; old players
  without RegisterCallback retain a compatibility-only polling fallback.
