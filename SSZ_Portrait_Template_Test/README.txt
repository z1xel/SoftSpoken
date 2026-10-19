SPOKEN INTERIOR — STANDALONE PORTRAIT FRAME TEST FOR TURTLE WOW 1.12

WHAT IT DOES
- Retains the successful older Blizzard-style portrait frame from the previous test.
- Recreates Spoken's two-pane Compendium arrangement using relative anchors.
- Uses actual Spoken_Places spellbook parchment and divider textures.
- Includes a tiled native gray-stone header and Marble list inset.
- Demonstrates search, expandable hierarchy, list scrolling, the Places/Books tabs,
  and page selection with SAMPLE CONTENT (not connected to real game data).

INSTALL
1. Back up your existing SSZ_Portrait_Template_Test addon folder.
2. Extract the ZIP into Interface/AddOns/, overwriting that test folder.
3. Existing art files UI-Frame.tga and !UI-Frame.tga will be preserved by the
   patch. If installing the full ZIP fresh, run Import-Art.ps1 as before.
4. Restart/reload Turtle WoW and type /sszportrait to toggle the window.
5. Click Places/Books, type in the search, expand groups, and click an item.
6. /sszsize shows/hides + and - test controls. Resize and check both panels.

SCOPE
This is ONLY the standalone SSZ_Portrait_Template_Test addon. Neither
SoftSpoken_Zones nor SoftSpoken_Books is modified.

FILES
Frame.lua & Frame.xml : identical to prior working portrait square-fix.
Interior.lua         : new standalone interior construction and sample rows.
Demo.lua             : window setup, separate test sizing/commands.
Textures/Art         : exact source art from user's Spoken_Places ZIP.

SOURCE REFERENCES
https://github.com/rusty-key/spoken-wow/blob/master/addons/Spoken/UI/Compendium.lua
https://github.com/rusty-key/spoken-wow/blob/master/addons/Spoken_Places/UI/LorePage.lua

Known difference from full upstream: this is a 1.12 demonstration using simple
inset outlines and rows; upstream has additional richer row styles, filtering,
art-atlas logic and production data. No full system integration attempted.

TESTED
Lua syntax parses. Desktop WoW-API simulation covered startup, resizing,
tab switching, text search and filter toggle. Final appearance is UNTESTED
inside Turtle WoW and needs an in-game screenshot.

Interior update: draggable resize grip
-------------------------------------
Drag the bottom-right diagonal grip with left mouse to resize continuously.
/sszsize still toggles the old +/- buttons.
The gray stone is now drawn behind the portrait.
The page uses Spoken Places' original Quest Log parchment.
No real game content was connected; it remains a standalone prototype.


PAGE INSET FIX: Quest Log page is now inside a 3-unit inner holder, with the original Spoken Places questlog-frame TGA nine-sliced above the parchment. Outer frame, search, list, tabs and drag-resize unchanged.
