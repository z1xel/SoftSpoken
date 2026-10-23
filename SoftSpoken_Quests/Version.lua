setfenv(1, VoiceOver)

-- Dedicated Turtle WoW 1.12 port: Quests shares Core's single target client.
-- Preserve the flags read by the Quest player, but not unreachable client modes.
Version={}
local client,build,_,interface=GetBuildInfo()
Version.Client=client
Version.Build=build
Version.Interface=interface or 0
Version.IsAnyLegacy=true
Version.IsLegacyVanilla=true

function Version:IsBelowLegacyVersion(target)
    return self.Interface<target or nil
end
function Version:IsRetailOrAboveLegacyVersion(target)
    return nil
end
