-- Regression contracts for the only supported Vanilla 1.12 settings host.
-- No new Retail Settings canvas, custom scroller or deferred search-navigation path.
local function read(path)
    local file = assert(io.open(path, "r"))
    local content = file:read("*a")
    file:close()
    return content
end
local opts = read("SoftSpoken/UI/Options.lua")
local layoutSource = read("SoftSpoken/UI/Layout.lua")
local function contains(haystack, needle, label)
    assert(haystack:find(needle, 1, true), label or needle)
end
local function absent(haystack, needle, label)
    assert(not haystack:find(needle, 1, true), label or needle)
end
contains(opts, 'UIPanelScrollFrameTemplate', "native 1.12 scroll template missing")
contains(opts, 'SSCNativeScrollbar.AttachSettings(panel, scroller)', "native silver scrollbar missing")
contains(opts, 'Search:BuildLegacy(panel)', "legacy search box missing")
contains(opts, 'function Options:SelectLegacyPage(order)', "tab navigation missing")
contains(opts, 'function Options:ShowRow(page, row)', "search result navigation missing")
contains(opts, 'scroller:GetVerticalScrollRange()', "search result scroll clamping missing")
contains(opts, 'scroller:SetVerticalScroll(offset)', "search result navigation must use native scroll")
contains(opts, 'UISpecialFrames', "Escape-to-close registration missing")
contains(layoutSource, 'function Layout:Intro(icon, title, text)', "module page heading missing")
contains(layoutSource, 'SpokenLayout = Layout', "shared layout export missing")
for _, disallowed in ipairs({
    "Settings.RegisterCanvasLayoutCategory",
    "RegisterCanvasLayoutSubcategory",
    "Layout.Scroll(",
    "Layout.OpenCategory(",
    "page.scroller",
    "page.category",
    "self.category",
    "C_Timer.After(",
}) do
    absent(opts, disallowed, "Retail option code remains: " .. disallowed)
    absent(layoutSource, disallowed, "Retail scroller remains: " .. disallowed)
end

-- Load the actual Options module, verify module-page registration still works,
-- including before Setup (modules initialize in an independent order).
local env = setmetatable({
    L = setmetatable({}, { __index = function(_, key) return key end }),
    Spoken = { Language = { LOCALES = {} } },
    SpokenLayout = {},
}, { __index = _G })
_G.SpokenEnv = env
assert(loadfile("SoftSpoken/UI/Options.lua"))()
local options = assert(env.Options)
local function pageFrame()
    local f = { hidden = false }
    function f:SetWidth(w) self.width = w end
    function f:SetHeight(h) self.height = h end
    function f:Hide() self.hidden = true end
    return f
end
local first, second = pageFrame(), pageFrame()
local firstResize = 0
local firstLayout = { onResize = function() firstResize = firstResize + 1 end,
    Height = function() return 80 end }
local secondLayout = { Height = function() return 60 end }
local b = options:AddPage(second, "Writings", 3, secondLayout)
local a = options:AddPage(first, "Stories", 1, firstLayout)
assert(a and b and a.order == 1 and b.order == 3, "addon pages must register")
local pages = options:Pages()
assert(#pages == 2 and pages[1] == a and pages[2] == b,
    "module pages must remain sorted before the home window initializes")
assert(first.width == 470 and second.width == 470 and first.hidden and second.hidden,
    "Vanilla module pages must start hidden with the same shared scroll width")
firstLayout.onResize(145)
assert(first.height == 112 and firstResize == 1,
    "module resize must keep the native scroll-child height and previous callback")
assert(not a.Open(), "uninitialized main settings window must not claim to open")
print("PASS: native settings, tab registration, search and scroll contracts retained")
