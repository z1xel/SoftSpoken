-- Text commands while the full upstream options/Compendium UI is being ported.
local B=SSB
local function Say(s) B:Print(s) end
local function Toggle(key)
    if not SSBSettings then B:InitDB() end
    SSBSettings[key]=not SSBSettings[key]
    Say(key.." "..(SSBSettings[key] and "on" or "off"))
    if B.RefreshOptions then B:RefreshOptions() end
end
SLASH_SOFTSPOKENBOOKS1="/spb"
SLASH_SOFTSPOKENBOOKS2="/spokenbooks"
SlashCmdList["SOFTSPOKENBOOKS"]=function(msg)
    local _,_,cmd=string.find(string.lower(msg or ""),"^%s*(%S*)")
    cmd=cmd or ""
    if cmd=="settings" or cmd=="options" then
        B:ShowOptions()
    elseif cmd=="books" or cmd=="library" or cmd=="compendium" then
        if B.ShowReadables then B:ShowReadables()
        else Say("Compendium unavailable; enable SoftSpoken_Zones") end
    elseif cmd=="inspect" then
        if B:IsMail() then Say("Mail excluded; nothing captured")
        else
            local title=ItemTextGetItem and ItemTextGetItem() or ""
            local page=ItemTextGetPage and ItemTextGetPage() or 1
            local raw=ItemTextGetText and ItemTextGetText() or ""
            local id=B:PageOnScreen()
            if id then
                local book=B:PlaceOf(id)
                Say("MATCH: "..tostring(title).." page "..tostring(page).." -> pageId "..tostring(id)..", bookId "..tostring(book))
            else
                Say("No match: "..tostring(title).." page "..tostring(page).." checksum "..tostring(B:ChecksumOf(raw)))
            end
        end
    elseif cmd=="status" then
        B:ShowBooksStatus()
        Say("Spoken player "..(B.source and "connected" or "not connected"))
        if table.getn(B:GetAudioPacks())==0 then Say(B:DescribeMissingAudio()) end
    elseif cmd=="read" or cmd=="play" then
        local id=B:PageOnScreen()
        if not id then Say("Open a recognized book first (mail is excluded)")
        elseif not B.source then Say("Spoken player unavailable")
        elseif not B:HasAudio(id) then Say(B:DescribeMissingAudio())
        elseif B:ReadCurrent()==0 then Say("Already queued, or no new pages") end
    elseif cmd=="stop" then
        B:StopReading()
        if B.RefreshPlayButton then B:RefreshPlayButton() end
    elseif cmd=="autoplay" then Toggle("autoplay")
    elseif cmd=="whole" then Toggle("readWholeBook")
    elseif cmd=="oneline" then Toggle("bookAsOneLine")
    elseif cmd=="once" then Toggle("readOnce")
    elseif cmd=="close" then Toggle("closeWhenRead")
    elseif cmd=="stoponclose" then Toggle("stopOnClose")
    elseif cmd=="debug" then Toggle("debug")
    elseif cmd=="unfound" then Toggle("unlockUnfound"); if B.RefreshReadables then B:RefreshReadables() end
    elseif cmd=="bytype" then Toggle("compendiumByZone"); if B.RefreshReadables then B:RefreshReadables() end
    elseif cmd=="forget" then Say("Forgot "..tostring(B:ForgetRead()).." readings")
    else
        Say("/spb options | books | status | inspect | read | stop | autoplay | whole | oneline | once | close | stoponclose | unfound | bytype | forget | debug")
    end
end
