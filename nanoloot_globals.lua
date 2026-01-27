NanoLoot = NanoLoot or {}

local Globals = {}
local LibStub = _G.LibStub
local LSM = nil
if LibStub then
    LSM = LibStub("LibSharedMedia-3.0", true)
end

Globals.LSM = LSM
Globals.Logo = "|cff9560FFnano|r|cffd5bfffloot|r"
Globals.Media = {
    FontPath = "Interface\\AddOns\\nanoloot\\Elements\\Fonts\\elements.ttf"
}
Globals.Layout = {
    Padding = 8,
    BarHeight = 20,
    PanelHeight = 40,
    PanelWidth = 320,
    LootListLimit = 20
}
Globals.Buttons = {
    Skip = {
        Background = { 90 / 255, 23 / 255, 45 / 255 },
        Border = { 30 / 255, 4 / 255, 12 / 255 },
        Label = { 255 / 255, 0 / 255, 84 / 255 },
        LabelShadow = { 64 / 255, 2 / 255, 22 / 255 },
        Highlight = { 107 / 255, 47 / 255, 66 / 255 }
    },
    Message = {
        Background = { 23 / 255, 90 / 255, 56 / 255 },
        Border = { 2 / 255, 21 / 255, 12 / 255 },
        Label = { 20 / 255, 236 / 255, 127 / 255 },
        LabelShadow = { 2 / 255, 58 / 255, 29 / 255 },
        Highlight = { 47 / 255, 107 / 255, 76 / 255 }
    }
}

NanoLoot.Globals = Globals

NanoLoot.Defaults = {
    LootList = {},
    TitleBarBackground = Elements.Palette.RGB.PURPLE,
    UseClassColour = false,
    HideWhenEmpty = false,
    UseCustomFont = false,
    CustomFontName = nil,
    CustomFontPath = nil,
    FontSize = 12,
    PanelPoint = "TOPLEFT",
    PanelRelativePoint = "TOPLEFT",
    PanelPositionX = 10,
    PanelPositionY = -10
}
