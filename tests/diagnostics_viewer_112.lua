-- WoW 1.12 UIPanelScrollFrameTemplate requires a globally named frame.
-- Exercise the real diagnostics UI with a lightweight frame/template harness.
local created, instances, templateCount = {}, {}, 0

local function MockFrame(name)
    local frame = { name = name, shown = false }
    function frame:GetName() return self.name end
    function frame:GetHeight() return rawget(self, "height") or 330 end
    function frame:SetHeight(height) self.height = height end
    function frame:SetText(value) self.text = value end
    function frame:GetText() return self.text end
    function frame:CreateFontString() return MockFrame(nil) end
    function frame:SetScript(script, fn) self[script] = fn end
    function frame:Show() self.shown = true end
    function frame:Hide() self.shown = false end
    setmetatable(frame, { __index = function() return function() end end })
    return frame
end

UIParent = MockFrame("UIParent")
UISpecialFrames = {}
SpokenEnv = setmetatable({}, { __index = _G })

function CreateFrame(frameType, name, parent, template)
    if template == "UIPanelScrollFrameTemplate" then
        templateCount = templateCount + 1
        assert(frameType == "ScrollFrame")
        assert(name == "SoftSpokenDiagnosticsScrollFrame",
            "Vanilla scroll templates require a stable named parent")
        assert(not created[name], "scroll template created twice")
    end
    if name then assert(not created[name], "duplicate frame name: " .. name) end
    local frame = MockFrame(name)
    frame.parent, frame.template = parent, template
    instances[#instances+1] = frame
    if name then
        created[name] = frame
        _G[name] = frame
    end
    if template == "UIPanelScrollFrameTemplate" then
        local scrollbar = MockFrame(name.."ScrollBar")
        created[name.."ScrollBar"] = scrollbar
        _G[name.."ScrollBar"] = scrollbar
    end
    return frame
end

dofile("SoftSpoken/UI/Diagnostics.lua")
local viewer = SpokenEnv.DiagnosticsViewer
assert(viewer:Show("Stories Diagnostics", {"|cff00ff00Pack loaded|r", "Audio CVar unavailable"}))
assert(templateCount == 1)
assert(created.SoftSpokenDiagnosticsScrollFrameScrollBar,
    "Vanilla must resolve its named scrollbar child")
assert(created.SoftSpokenDiagnosticsWindow.shown)
assert(created.SoftSpokenDiagnosticsScrollFrameScrollBar:GetName()
    == "SoftSpokenDiagnosticsScrollFrameScrollBar")
assert(viewer:Show("Stories Diagnostics", "Second report"))
assert(templateCount == 1, "viewer must reuse its existing frames")
assert(#UISpecialFrames == 1 and UISpecialFrames[1] == "SoftSpokenDiagnosticsWindow")
print("PASS: Vanilla-named diagnostics scroll template, display and reuse")
