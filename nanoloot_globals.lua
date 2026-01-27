NanoLoot = NanoLoot or {}

local LibStub = _G.LibStub
local LSM
if LibStub then
    LSM = LibStub("LibSharedMedia-3.0", true)
end

local Constants = {
    LOGO = "|cff9560FFnano|r|cffd5bfffloot|r",
    FONT_PATH = "Interface\\AddOns\\nanoloot\\Elements\\Fonts\\elements.ttf",
    PADDING = 8,
    BAR_HEIGHT = 20,
    PANEL_HEIGHT = 40,
    PANEL_WIDTH = 320,
    LOOTLIST_LIMIT = 20,
    BUTTONS = {
        SKIP_BG = { 90 / 255, 23 / 255, 45 / 255 },
        SKIP_BORDER = { 30 / 255, 4 / 255, 12 / 255 },
        SKIP_LABEL = { 255 / 255, 0 / 255, 84 / 255 },
        SKIP_LABEL_SHADOW = { 64 / 255, 2 / 255, 22 / 255 },
        SKIP_HIGHLIGHT = { 107 / 255, 47 / 255, 66 / 255 },
        MSG_BG = { 23 / 255, 90 / 255, 56 / 255 },
        MSG_BORDER = { 2 / 255, 21 / 255, 12 / 255 },
        MSG_LABEL = { 20 / 255, 236 / 255, 127 / 255 },
        MSG_LABEL_SHADOW = { 2 / 255, 58 / 255, 29 / 255 },
        MSG_HIGHLIGHT = { 47 / 255, 107 / 255, 76 / 255 }
    }
}

local Defaults = {
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

NanoLoot.Globals = {
    LSM = LSM,
    Constants = Constants,
    Defaults = Defaults
}
