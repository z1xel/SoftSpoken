-- OPTIONAL, READ-ONLY-UNTIL-SELECTED bridge into the REAL SoftSpoken Places tree.
-- Standalone prototype still opens with the exact frozen Books screenshot.
-- This file does NOT import lore data, replace live addons, or draw UI.
-- Uses the public SSZLoreWindow row/selection API exposed by the real Zones addon.
SSZPortraitLivePlaces={}
local B=SSZPortraitLivePlaces

local function Source()
    local m=SSZLoreWindow
    if type(m)=="table" and type(m.RebuildRows)=="function" and
       type(m.Select)=="function" and type(m.PageEntry)=="function" then
        return m
    end
    return nil
end
function B.Available() return Source()~=nil end
function B.Rows()
    local m=Source()
    if not m then return nil end
    -- Real module alone determines hierarchy, discovery, search and ordering.
    local ok,rows=pcall(m.RebuildRows)
    if not ok or type(rows)~="table" then return nil end
    local result={}
    for i=1,table.getn(rows) do
        local row=rows[i]
        local done,total=tonumber(row.count) or 0,tonumber(row.total) or 0
        local percent=total>0 and tostring(math.floor(done*100/total)).."%" or ""
        result[i]={
            source=row, label=row.label or row.name or "",depth=row.depth or 0,
            group=not row.leaf and tostring(row.kind)..":"..tostring(row.id) or nil,
            open=row.open, locked=row.locked, count=total>0 and
                (tostring(done).."/"..tostring(total)) or "", percent=percent
        }
    end
    return result
end
function B.Selected(row)
    local m=Source()
    if not m or type(m.IsSelected)~="function" then return false end
    local ok,selected=pcall(m.IsSelected,row)
    return ok and selected or false
end
function B.Select(row)
    local m=Source()
    if not m or row.locked then return false end
    return pcall(m.Select,row)
end
function B.Search(query)
    local m=Source()
    if not m or type(m.SetSearch)~="function" then return false end
    return pcall(m.SetSearch,query or "")
end
function B.Page()
    local m=Source()
    if not m then return nil end
    local ok,page=pcall(m.PageEntry)
    if ok and type(page)=="table" then return page end
    return nil
end
