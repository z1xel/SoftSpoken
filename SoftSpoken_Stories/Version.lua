setfenv(1, VoiceOver)

-- Shared 1.12 client definition from mandatory SoftSpoken Core.
-- Keep this small binding here so existing Quests load order stays unchanged.
Version = assert(Spoken and Spoken.Version,
    "SoftSpoken Core 1.12 version service is required")
