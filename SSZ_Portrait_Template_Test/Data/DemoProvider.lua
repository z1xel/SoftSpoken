-- Compatibility fixture for the visual prototype only. Never transfer this
-- sample data or demonstration discovery state to the production Compendium.
-- The original rows and page copy have been moved here unchanged.
local BOOKS = {
 {label="Azeroth",depth=0,group="world",count="0/399",percent="0%"},
 {label="Kalimdor",depth=1,group="kalimdor",parent="world",count="0/123",percent="0%"},
 {label="Azshara",depth=2,parent="kalimdor",count="0/5",percent="0%"},
 {label="Darkshore",depth=2,parent="kalimdor",count="0/6",percent="0%"},
 {label="Desolace",depth=2,parent="kalimdor",count="0/6",percent="0%"},
 {label="Durotar",depth=2,parent="kalimdor",count="0/30",percent="0%"},
 {label="Feralas",depth=2,parent="kalimdor",count="0/5",percent="0%"},
 {label="Moonglade",depth=2,parent="kalimdor",count="0/5",percent="0%"},
 {label="Mulgore",depth=2,parent="kalimdor",count="0/13",percent="0%"},
 {label="Silithus",depth=2,parent="kalimdor",count="0/14",percent="0%"},
 {label="Tanaris",depth=2,parent="kalimdor",count="0/6",percent="0%"},
 {label="Teldrassil",depth=2,parent="kalimdor",count="0/14",percent="0%"},
 {label="Eastern Kingdoms",depth=1,group="eastern",parent="world",count="0/249",percent="0%"},
 {label="Elwynn Forest",depth=2,parent="eastern",count="0/14",percent="0%"},
 {label="Tirisfal Glades",depth=2,parent="eastern",count="0/8",percent="0%"},
}
local PLACES = {
 {label="Azeroth",depth=0,group="world",count="1/2",percent="50%"},
 {label="Kalimdor",depth=1,group="kalimdor",parent="world",count="1/18",percent="5%"},
 {label="Ashenvale",depth=2,parent="kalimdor",count="0/40",percent="0%"},
 {label="Azshara",depth=2,parent="kalimdor",count="0/30",percent="0%"},
 {label="Darkshore",depth=2,parent="kalimdor",count="0/15",percent="0%"},
 {label="Desolace",depth=2,parent="kalimdor",count="0/20",percent="0%"},
 {label="Durotar",depth=2,parent="kalimdor",count="0/27",percent="0%"},
 {label="Feralas",depth=2,parent="kalimdor",count="0/28",percent="0%"},
 {label="Moonglade",depth=2,parent="kalimdor",count="0/5",percent="0%"},
 {label="Mulgore",depth=2,parent="kalimdor",count="0/22",percent="0%"},
 {label="Teldrassil",depth=2,parent="kalimdor",count="7/17",percent="41%"},
 {label="Eastern Kingdoms",depth=1,group="eastern",parent="world",count="0/19",percent="0%"},
 {label="Elwynn Forest",depth=2,parent="eastern",count="0/24",percent="0%"},
 {label="Tirisfal Glades",depth=2,parent="eastern",count="0/31",percent="0%"},
}


SSZPortraitDemoProvider = {}
local D = SSZPortraitDemoProvider

function D:GetRows(mode, state)
    return mode=="books" and BOOKS or PLACES
end
function D:GetPage(mode, record, state)
    if not record then
        if mode=="books" then
            return {title="READABLES", subtitle="Books, letters, notes and plaques",
                text="Choose a writing from the list to read its pages."}
        end
        return {title="CHOOSE A PLACE", subtitle="",
            text="Select a location from the list to read its history."}
    end
    if mode=="books" then
        return {title=string.upper(record.label),subtitle="Writings of Azeroth",
            text="This is a standalone visual test of Spoken's reading page. Actual books and their text will be connected when the interface is integrated."}
    end
    return {title=string.upper(record.label),subtitle="Azeroth's places",
        text="This is a standalone visual test of Spoken's lore page. Real zone histories will be connected when the interface is integrated."}
end
function D:Visible(mode, row, query, state)
    if query~="" then return string.find(string.lower(row.label),query,1,true)~=nil end
    if state.foundOnly and (row.count==nil or string.sub(row.count,1,1)=="0") then return false end
    if row.parent and not state.open[row.parent] then return false end
    if row.depth==2 and not state.open.world then return false end
    return true
end
function D:CanSelect(mode, row, state)
    return state.unlockUndiscovered or
        (row.count and string.sub(row.count,1,1)~="0")
end
function D:Counter(mode, row, state)
    return (row.count or "").." - "..(row.percent or "")
end
function D:GetFilters(mode, state)
    return {
        {id="found",text="Discovered Only",checked=state.foundOnly,
            toggle=function() state.foundOnly=not state.foundOnly end},
        {id="voiced",text="Voiced Only",disabled=true,
            tooltipTitle="Voiced Only",
            tooltipText="Available when real narrated entries are connected."},
        {id="unlock",text="Unlock Undiscovered",
            checked=state.unlockUndiscovered,
            toggle=function() state.unlockUndiscovered=not state.unlockUndiscovered end},
    }
end
