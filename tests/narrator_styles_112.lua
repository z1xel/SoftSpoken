-- Vanilla 1.12 supports Classic Window and Voice Only, with no third narrator tiles.
-- Execute the real options definitions without constructing a client UI.
local labels = setmetatable({}, { __index = function(_, key) return key end })
local env = setmetatable({
    L = labels,
    Spoken = { Language = { LOCALES = {} } },
    SpokenLayout = {
        Rect = function(art)
            art.rectangles = (art.rectangles or 0) + 1
        end,
    },
}, { __index = _G })
_G.SpokenEnv = env
assert(loadfile("SoftSpoken/UI/Options.lua"))()
local options = assert(env.Options)
local styles = options:Styles()
assert(table.getn(styles) == 2 and styles[1] == "classic" and styles[2] == "none",
    "only Classic Window and Voice Only should be offered")
local supported = { classic = true, none = true }
for _, metadata in ipairs({
    options.STYLE_LABELS, options.STYLE_TEXTS, options.STYLE_TIPS, options.SKETCHES,
}) do
    local count = 0
    for style in pairs(metadata) do
        assert(supported[style], "unsupported narrator metadata: " .. tostring(style))
        count = count + 1
    end
    assert(count == 2, "narrator metadata must match supported styles exactly")
    for _, style in ipairs(styles) do
        assert(metadata[style] ~= nil, "missing metadata for " .. style)
    end
end
for _, style in ipairs(styles) do
    local art = { width = 120 }
    options.SKETCHES[style](art)
    assert((art.rectangles or 0) > 0, "missing narrator sketch for " .. style)
end

-- Old saved style values must continue falling back to Classic Window, not be deleted
-- or interpreted as Voice Only. Core's profile migration is intentionally untouched.
local core = assert(io.open("SoftSpoken/Core.lua", "r")):read("*a")
assert(core:find('return self:Profile("Frame").Style == "none" and "none" or "classic"', 1, true),
    "old profile styles must still fall back to Classic Window")
assert(core:find('self.db.profile.Frame.Style = style == "none" and "none" or "classic"', 1, true),
    "new style choices must remain limited to Classic Window and Voice Only")
print("PASS: only two supported narrator styles; legacy profile fallback preserved")
