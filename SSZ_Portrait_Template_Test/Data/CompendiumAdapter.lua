-- Transfer-only bridge for the existing SSCCompendium C.NewList opts interface.
-- Do not replace production Compendium list/tree/discovery/navigation logic:
-- each opts.build(), opts.isSelected(), opts.onClick(), opts.onSearch(), etc.
-- remains authoritative. This adapter lets the APPROVED prototype renderer
-- consume the same callback contract while porting the skin.
-- No production modules are loaded or patched in the standalone test.

SSZPortraitCompendiumAdapter = {}
local Bridge=SSZPortraitCompendiumAdapter

local function CountString(row)
    if row.leaf then return "" end
    if row.total and row.total>0 then
        return tostring(row.count or 0).."/"..tostring(row.total)
    end
    return row.count and tostring(row.count) or ""
end

local function Normalize(row,idx)
    local branch=(not row.leaf)
    local count=CountString(row)
    local pct=""
    if branch and row.total and row.total>0 then
        pct=tostring(math.floor(100*(row.count or 0)/row.total)).."%"
    end
    return {
        source=row, label=row.label or row.name or "",
        depth=row.depth or 0,
        group=branch and tostring(row.id or row.key or row.mapID or ("branch"..idx)) or nil,
        open=row.open,locked=row.locked,
        count=count,percent=pct,
        counterText=row.leaf and "" or
            (row.total and row.total>0 and count.." - "..pct or count)
    }
end

-- Specs per mode are the SAME list options that the real Compendium passes
-- to SSCCompendium.NewList(panel, opts). Supported extra callback:
-- page(row, mode) -> {title, subtitle, text} for the prototype reading page.
-- The production LorePage and TextView remain authoritative after transfer.
function Bridge.New(specs)
    local adapter={specs=specs or {}, cache={}}
    local function Options(mode) return adapter.specs[mode] or {} end
    function adapter:GetRows(mode,state)
        local opts=Options(mode)
        local source=opts.build and opts.build() or {}
        local output={}
        for i=1,table.getn(source) do
            output[i]=Normalize(source[i],i)
        end
        self.cache[mode]=output
        return output
    end
    function adapter:Visible(mode,row,query,state)
        -- opts.build() owns upstream search, expansion and nested discovery.
        return true
    end
    function adapter:CanSelect(mode,row,state)
        return not row.locked
    end
    function adapter:IsSelected(mode,row,state)
        local opts=Options(mode)
        return opts.isSelected and opts.isSelected(row.source) or false
    end
    function adapter:Counter(mode,row,state)
        return row.counterText
    end
    function adapter:OnSelect(mode,row,state)
        local opts=Options(mode)
        if opts.onClick then opts.onClick(row.source) end
    end
    function adapter:OnToggleGroup(mode,row,state)
        local opts=Options(mode)
        if opts.onClick then opts.onClick(row.source) end
    end
    function adapter:OnSearch(mode,query,state)
        local opts=Options(mode)
        if opts.onSearch then opts.onSearch(query) end
    end
    function adapter:GetPage(mode,row,state)
        local opts=Options(mode)
        local entry=opts.page and opts.page(row and row.source or nil,mode)
        if entry then return entry end
        return {title=row and string.upper(row.label or "") or
                    (mode=="books" and "READABLES" or "CHOOSE A PLACE"),
                subtitle="",text=""}
    end
    function adapter:GetFilters(mode,state)
        local opts=Options(mode)
        local entries={}
        if opts.only then
            local item={text=opts.only,checked=opts.onlyGet and opts.onlyGet(),
                toggle=function()
                    if opts.onlySet then opts.onlySet(not (opts.onlyGet and opts.onlyGet())) end
                end}
            table.insert(entries,item)
        end
        for _,check in ipairs(opts.checks or {}) do
            local function ToggleCheck(c)
                return function() c.set(not c.get()) end
            end
            table.insert(entries,{text=check.label,checked=check.get(),
                toggle=ToggleCheck(check)})
        end
        return entries
    end
    return adapter
end
