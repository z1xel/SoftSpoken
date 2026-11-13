-- Run from the repository root: lua5.1 tests/compendium_book_mask.lua
-- Ensure the Compendium book uses one masked texture and a circular alpha asset.
local path = "SoftSpoken/Compendium/UI/FrameSkin.lua"
local file = assert(io.open(path, "r"))
local skin = file:read("*a")
file:close()

assert(not string.find(skin, "local function circularIcon", 1, true),
    "legacy one-pixel strip renderer must be removed")
assert(not string.find(skin, "sszPortraitSlices", 1, true),
    "old strip collection must not be retained")
assert(string.find(skin, 'local BOOK_ICON = "Interface\\\\Icons\\\\INV_Misc_Book_11"', 1, true),
    "use the original inventory book icon")
assert(string.find(skin, "book:SetMask(BOOK_MASK)", 1, true),
    "use ClassicAPI to mask the single book texture")
assert(string.find(skin, "self.sszBookIcon = maskedBookIcon(self, -6, 8, 61)", 1, true),
    "preserve the original book placement")

local maskPath = "SoftSpoken/Compendium/Textures/Skin/BookPortraitCircleMask.tga"
local mask = assert(io.open(maskPath, "rb"))
local image = mask:read("*a")
mask:close()
local byte = string.byte
assert(#image == 18 + 64*64*4, "expected uncompressed 64x64 RGBA TGA")
assert(byte(image, 3) == 2 and byte(image, 17) == 32 and byte(image, 18) == 40,
    "expected 32-bit TGA with top-left origin")
local function alpha(x, y)
    return byte(image, 18 + (y*64+x)*4 + 4)
end
assert(alpha(0, 0) == 0 and alpha(63, 63) == 0, "corners must be transparent")
assert(alpha(31, 31) == 255 and alpha(32, 32) == 255,
    "book center must be fully opaque")
assert(alpha(0, 32) == 0 and alpha(32, 0) == 0,
    "the mask must clip outside the portrait ring")
print("PASS: Compendium book uses one circularly masked original inventory icon")
