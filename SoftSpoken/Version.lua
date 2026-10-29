setfenv(1, SpokenEnv)

-- This fork targets Turtle WoW's 1.12 client exclusively. Keep the existing
-- Version interface because the player, UI, and queue still read its flags.
Version = {}
local client, build, _, interface = GetBuildInfo()
Version.Client = client
Version.Build = build
Version.Interface = interface or 0
Version.IsAnyLegacy = true
Version.IsLegacyVanilla = true

-- Unset flags (Retail, TBC, Wrath, Forever) intentionally evaluate as nil.
-- Preserve the helpers used by the existing UI and profile defaults.
function Version:IsBelowLegacyVersion(version)
    return self.Interface < version or nil
end
function Version:IsRetailOrAboveLegacyVersion(version)
    return self.Interface >= version or nil
end

-- Core is the authoritative version service for all SoftSpoken modules.
-- This describes the target 1.12 runtime; module-specific addons reuse it.
Spoken.Version = Version
