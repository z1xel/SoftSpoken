# Location architecture — L2 contract (v1)

Status: accepted design, not runtime implementation. Baseline: [L1 audit](LOCATION_ARCHITECTURE_AUDIT.md) at `4720d00`. The five approved decisions are binding: immutable semantic IDs; all reliably identifiable locations independently of content; separate content ownership; Vanilla base plus server/client overlays; eventual adoption by all modules and geographical persistence. Historical exploration recovery is explicitly outside this phase.

## 1. Ownership and boundaries

The shared registry is the authoritative source of geographical identity, names, classification, identifier bindings and geographical relations. It does not own lore, pictures, voice packs, quests, books, player history, map geometry, or quest categories. A location may have no associated content and must still be a valid entity. Existence in a source is not proof of current client availability, reachability, or player discovery.

Use ordinary data tables and a shared service, compatible with Lua 5.0. No per-location objects, generic graph framework, new addon dependency, or runtime source generation is required. Runtime indexes derive from generated records. Source reconciliation happens offline.

Planned physical boundaries:
- SoftSpoken/Locations/Registry.lua: shared read-only-by-contract query service; initialized before the Compendium name wrappers and feature consumers.
- SoftSpoken/Locations/Data/Base.lua: generated geographical entities and base native bindings.
- SoftSpoken/Locations/Data/<client>.lua: generated overlay definitions and client-specific bindings, loaded without copying the whole base catalog.
- SoftSpoken/Locations/Data/MapBindings.lua (or split by client): map representation associations; no texture geometry.
- Independent module content datasets and adapters reference canonical IDs; the legacy external pack format remains supported.
- tools/locations/: pinned inputs manifest, stable ID manifest, reviewed corrections, generator, validation, coverage reports. No generated data in L2.

These paths are design targets, not added files. Data files may be split further for size without changing the contract.

## 2. Canonical identity

A location is an independently identifiable geographical entity, not an AreaTable row, a map image, a named string, or a lore entry.

Canonical ID: ASCII lowercase segments matching `[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)*`. Examples: `elwynn_forest`, `elwynn.goldshire`, `deadmines`. Qualify names only when useful for disambiguation. Segments are lexical labels, NOT a path from which parent or server is inferred. Once allocated, keys survive changes in names, maps, hierarchy, or supported clients.

The checked-in ID manifest is the allocation authority: each entry records canonical ID, status (active/retired), evidence anchors, and any explicit redirect or split decision. Generation consumes it; it must never generate a new ID on each run from the current name, silently reassign an ID, recycle a retired ID, or resolve collisions by source row order. New IDs require deterministic proposal and explicit acceptance in the manifest. A new entity discovered on Turtle need not have a Turtle-prefixed ID unless disambiguation requires it.

Merge: select a surviving ID explicitly; retain the retired ID as a redirect with evidence. Split: retain the old ID as unresolved unless its original meaning clearly maps to exactly one successor; record candidate successors, never fan out player history automatically. Redirects must be acyclic and resolve to active IDs; splits are not redirects. Unknown persisted IDs are retained, not discarded.

Identity reconciliation uses corroborated identifiers, geographical context, names, and reviewed evidence. Equal names do not prove identity. Equal numeric native IDs across client datasets do not prove identity. Different IDs or different map representations do not by themselves prove distinct entities.

## 3. Entity schema

The following is illustrative Lua, not a production mapping. The key is the canonical ID; no duplicate id field is required.

```lua
Base = {
    ["elwynn.goldshire"] = {
        name = "Goldshire",
        kind = "settlement",
        parent = "elwynn_forest",
        aliases = {
            enUS = { "Goldshire" },
        },
    },
}
```

| Field | Type | Rule |
| --- | --- | --- |
| name | nonempty string | canonical display name, English fallback; exact spelling retained |
| kind | enum | world, continent, zone, city, subzone, settlement, landmark, interior, dungeon, raid, battleground, arena, unknown |
| parent | canonical ID or omitted | primary geographical containment only; absent when unknown or root |
| aliases | locale -> array of nonempty strings, optional | alternate or localized lookup names, not IDs |
| names | locale -> nonempty string, optional | preferred localized display names; fallback to name |
| identifiers | namespace -> list of numeric IDs, optional in effective view | computed from bindings scoped to selected client or pinned content namespace; see section 4 |

No invented parent or classification to satisfy a schema. Generic subzone/unknown is appropriate when evidence is incomplete. City is a kind, not a claim that it has a dedicated map. Seasonal status is an availability/context property, not a new geographical kind; preserve old presentation categories in consumer projections when needed.

The generated registry may store identifiers as separate binding rows to avoid copying base entities on overlays. The effective logical entity still exposes its associated identifiers through the service. No arbitrary nested extension fields: additions require a documented schema revision.

## 4. Identifier and representation contracts

Namespaces are explicit, scoped, and never interchangeable.

| Namespace | Scope | Meaning / constraint |
| --- | --- | --- |
| areaTable | native client data profile | positive AreaTable ID, not exploration bit |
| upstreamUiMap | pinned Spoken/Classic-compatible content ID space | positive UiMapID; external content compatibility |
| nativeUiMap | native client data profile + API convention | nonzero signed native ID; positive AreaTable-based, negative row-based on ClassicAPI v1.23.9 |
| worldMapArea | native client data profile | positive WorldMapArea row ID |
| instanceMap | native client data profile | nonnegative Map.dbc ID that identifies an instance, not an arbitrary outdoor map |
| worldMap | native client data profile | nonnegative Map.dbc world ID; belongs to representation data; cannot resolve an arbitrary zone |

AreaTable exploration indexes, overlay row IDs, names and texture directory names are NOT entity identifiers. Overlay row IDs and geometry belong to the map service.

Bindings are authored/generated separately from base identity:

```lua
-- Example only: existing upstream and native namespaces are distinct.
Bindings = {
    { scope = "vanilla_112", namespace = "areaTable",
      value = 87, location = "elwynn.goldshire" },
    { scope = "spoken_classic", namespace = "upstreamUiMap",
      value = 1429, location = "elwynn_forest" },
}
```

A binding means that the external identifier identifies this entity in that namespace and scope; it does not merely overlap it geographically. Several external IDs may identify the same entity. One external ID in a resolved scope should identify at most one canonical entity; unresolved multi-candidate identifiers belong to the offline hold report, not the active index. Scope selection must not silently choose one competing record. An input can yield ambiguous rather than resolved. Outdoor Map.dbc 0/1 are not shortcuts to zones; world map lookup is representation context.

Map representation is a separate contract:

```lua
-- Schematic reference, not production data.
MapRepresentation = {
    scope = "vanilla_112",
    namespace = "worldMapArea",
    value = 123,
    subject = "elwynn_forest",
}
MapCoverage = {
    location = "elwynn.goldshire",
    map = { scope = "vanilla_112", namespace = "worldMapArea", value = 123 },
}
```

The representation has a subject (the place it depicts as a map); coverage relates other entities to it. A map without a proven subject is an unresolved representation, not a new location. Multiple representations may depict one entity; multiple entities may appear on a map. Direct map ownership and coverage are distinct. GetMaps returns qualified map references, not bare numbers. Physical geometry, overlays, rendering and coordinate transforms remain outside the identity registry.

## 5. Geographical relationships

Three distinct relationship classes:
1. Primary containment: child -> parent. At most one primary parent in an effective client view; acyclic, no self-edge, all targets active. It is a navigation projection of verified containment, not proof of unique physical ownership. Derive children and ancestor chain, never persist inverse lists.
2. Additional containment: optional verified `within` edges for cross-boundary places. Separate from primary navigation parent; containment graph including these edges must be acyclic. If multiple plausible parents cannot be distinguished, no primary parent is manufactured. A reviewed presentation choice may select a primary among verified parents, documented in the correction manifest.
3. Geographical association: `associatedWith` and `entranceIn` edges. Association is symmetric by meaning (store once, derive inverse); entranceIn is directional from instance to entrance location. Neither implies containment, discovery, or automatic inheritance. A dungeon entrance and interior remain distinct if evidence describes distinct places.

Represent additional edges as records `{ from, relation, to }` keyed by the canonical IDs. No generic relation type beyond the above is needed in v1; module-specific content associations belong to content datasets. Cross-zone Blackrock Mountain and similarly named subzones require individual adjudication, not a global merge rule. Presentation trees may project an entity under multiple branches without duplicating its identity.

## 6. Fixed Octo client scope

OctoWoW is the sole supported runtime target for the current implementation. The native identifiers come from the pinned Octo client export. No server detection, live DBC fingerprints, compatibility probes, automatic profile selection, or native extensions. The offline manifest preserves provenance and checksums for reproducible builds, not runtime activation.

The existing base and Octo overlay decisions are composed offline into a single effective view. Explicit add/patch operations, namespace separation, stable identities, and validation are retained. Runtime loads the fixed scope directly; it does not evaluate or stack overlays. Other worlds are out of scope until support is explicitly revisited.

Existence in the catalog is not proof of reachability or discovery. Missing or ambiguous identifiers remain unresolved. The data schema does not require a separate startup dependency.

## 7. Content compatibility and crosswalks

Independent module-owned datasets reference canonical IDs. No lore/audio/picture/quest/book payload or links are stored as fields of the geographical entity. Derived content indexes, when needed, are owned by the relevant consumer.

Legacy Places keys are exact tuples `(upstreamUiMapID, normalizedEnglishSubzoneKey)`; zone overview uses the empty key. Do not concatenate ambiguous strings into lookup keys without escaping; nested tables are sufficient. A content binding maps each legacy tuple to a canonical location ID only when verified. Multiple tuples can map to one location; preserve all original content variants and their map context. A canonical location can have multiple independent lore/artwork/recording entries; no overwrite or arbitrary choice based on index order. Content selection is a module concern (explicit requested context, existing priority rules); unresolved selection remains unresolved.

Keep upstream voice-pack globals, file paths, language selection and priority policies unchanged. Resolve canonical ID -> candidate legacy bindings at the Places boundary; use exact existing pack lookup. The audio transport clip key is a playback contract, not canonical geographical identity. Quest and book ID spaces remain unchanged. Stories' zones, turtleArea and dungeon fields are separately interpreted with a known source scope, then converted; quest sorts remain outside geography. Preserve multi-location membership, old category grouping and approved holds. Writings' source-name index, acquisition method and wide flag remain independent of geography.

L3 validates every shipped reference (including Writings from tuples, not only zones arrays). Unresolved bindings stay in explicit coverage reports and legacy compatibility adapters until resolved; do not drop existing content to make a validator pass. New canonical-only references require known active/retained IDs. No third-party source dataset is overwritten just to impose internal IDs.

## 8. Query contract (L6 target)

The service is read-only by convention. Never let consumers mutate shared tables; no copying the whole registry per request. Collection order is deterministic (canonical ID unless a presentation layer requests explicit sort). Build indexes once for a selected effective profile; no full-table scan per lookup.

```lua
Locations:Get(locationID)                         -- entity or nil
Locations:ResolveIdentifier(namespace, value, scope) -- id, status, candidates?
Locations:ByAreaID(areaID, scope)                  -- same resolution contract
Locations:ByUiMapID(uiMapID)                       -- upstream namespace ONLY
Locations:ByNativeMapID(mapID, scope)              -- nativeUiMap namespace
Locations:ByInstanceMapID(mapID, scope)
Locations:ResolveName(name, context)               -- id, status, candidates?
Locations:ResolveLegacyPlace(mapID, areaKey)       -- id, status, candidates?
Locations:GetParent(locationID)                    -- id or nil
Locations:GetChildren(locationID)                  -- ordered ID array
Locations:GetAncestors(locationID)                 -- nearest first, primary chain
Locations:GetRelations(locationID, relation)       -- ordered ID array
Locations:GetMaps(locationID)                     -- qualified representations
Locations:GetName(locationID, locale)              -- preferred name or fallback
Locations:GetAvailability(locationID)             -- present/absent/unknown
```

Canonical identity resolution follows explicit redirects, reports retired unresolved splits rather than guessing. Status for resolver functions is `resolved`, `unknown`, `ambiguous`, or `unavailable`; only resolved returns an ID. Ambiguous candidates are ordered, not used as fallbacks by caller. Missing scope for a native namespace uses the fixed Octo scope; unsupported scopes return unavailable. Legacy content key is not a native identifier. Get(id) does not turn a split into a live entity; diagnostics can inspect retained manifest records separately.

Name resolver uses exact localized/display name then normalized alias matching under explicit context (locale, scope, parent/map/instance constraints). Name normalization is not identity: retain exact original string, use existing English legacy normalization only for pack keys, and define locale-safe matching in L6; Lua 5.0 string.lower is not Unicode casefolding. Do not strip articles/punctuation across all languages as if universal. Apply only proven contextual constraints; if several distinct IDs remain, ambiguous. Do not choose first result. Current player location adapter obtains native evidence where available, otherwise existing zone/subzone text; displayed world map never establishes player location. No changing zoom or opening map to resolve identity.

## 9. Persisted geographical references (L10 target)

Only character-owned observed state is migrated; geographical registry and source metadata never enter SavedVariables. Preserve profile settings and existing D migration ledger. Use an independent character geography schema version, not a new account database. Target shape subject to L10 validation against real fixtures:

- Places.visited: canonical location ID -> true. Merge proven equivalent keys with boolean OR.
- Places.heard: canonical location ID -> set of heard content identities. Preserve the distinction between heard geography and heard recording variants. Do not mark all independent legacy bindings as heard just because two resolve to one entity; a module can define an explicit equivalence where recordings represent the same content. Playback keys remain separate and existing autoplay suppression behavior preserved via adapter.
- Writings.locations: book ID -> canonical location ID -> set of observed acquisition method strings. Merge by union; do not invent specific subzones for old zone observations. Read/display adapters preserve existing location summaries; any method selection is presentation-only.
- Writings.acquisitions: item ID -> canonical location ID -> outstanding quantity. Sum distinct confirmed legacy counters resolving to same location; never multiply a counter across candidate locations. Preserve bag reconciliation behavior.
- Places.greeted, Writings.read/found, Stories quest state and dialogue, account prefs/layout remain unchanged.

Unmapped, ambiguous, inactive, and split legacy observations must be losslessly retained under a versioned quarantine/legacy envelope carrying original field, typed key/value and source context. No fabricated canonical location and no silent fan-out. Legacy-compatible read path remains until resolved; do not suppress legitimate existing history solely because new registry lacks a mapping. Reconciliation of held records after a later catalog update is explicit and idempotent; never count migrated counters twice. Heard semantics require variant identity decisions before L10; default preserve distinct legacy evidence.

L10 migration runs after D legacy import or existing unified data load, before modules consume geographical state. Stage a detached transformation, validate all fields and counts, then publish and mark per-character version together; failure leaves old state and blocks unsafe conversion, without modifying external legacy files or account migration ledger. Repeated login/reload is a no-op for already migrated data. No support for unreleased intermediate development snapshots beyond the current tested migration baseline is implied. Full WTF backup and actual client validation remain required.

## 10. Generator and validation contract

L3 inputs: exact source revision/checksum, source schema/locale, client profile, provenance and redistribution permission. Keep full source evidence and conflict reports offline; runtime output contains lean names, classifications, associations and qualified identifier bindings only. Stable ID manifest and reviewed corrections are source-controlled; regenerated Lua deterministic with stable ordering and escaping. No new canonical allocation from unreviewed fuzzy matching.

Required checks before L4/L5 publication:
- schema types, enum and ID grammar; no recycled IDs or redirect cycles;
- each overlay validates effective entity graph, references, containment and availability;
- namespace/scope validity, no conflicting active bindings; explicit repurposed IDs;
- coverage for all reliably identified source entities, with distinct excluded nonlocations/unused/unknown/held buckets and reasons; don't equate raw row count with entity count;
- all existing consumer keys counted, mapped or explicitly held, including non-geographical quest sorts kept separate;
- multi-map and duplicate-name cases; aliases with context; no map representation conflated with entity;
- provenance for accepted identity merges/splits and corrections, reproducible identical output from pinned inputs;
- no lore or other content fields in registry records;
- existing Lua 5.0 client compatibility and existing regression suites, no changes to public pack contracts.

L6 tests resolver statuses, deterministic indexes, unsupported scopes, fixed Octo data, cross-boundary relationships, map reference namespaces, no mutation/side effects. L7–L9 compare existing consumer output before and after each adapter migration. L10 tests both original released legacy imports and consolidated DB, held keys, merges, distinct recordings, methods and quantities, redirects/splits, failed transform and reload. L11 measures startup/memory on real client and validates all consumers. No historical discovery recovery in L2–L6; subsequent feature can query area identity without reshaping the model.

## 11. Open evidence, not open architecture

L1 did not acquire authoritative raw Vanilla/Turtle/Octo DBC inputs or exact upstream modern UiMap snapshot. L3 must acquire/verify them or explicitly report gaps. Runtime world/native-profile selection is out of scope under the fixed Octo target. Real identity decisions for repeated names, multi-area places, instance entrance relationships and repurposed IDs belong in the reviewed manifest during L4/L5. No production entity mappings are approved by illustrative examples above.

Design choices made within the approved five decisions: semantic ID grammar; scoped bindings separate from record storage; one primary containment plus optional verified additional containment; strict unresolved resolution; no implicit overlay deep merge; preserve independent heard variants and acquisition methods; conservative migration holds. These defaults avoid inventing geography or losing existing state. Exact implementation details and evidence-driven exceptions can be refined in later phases without changing the agreed architecture.

L2 is complete when this contract is committed. No runtime or data migration is performed by L2.
