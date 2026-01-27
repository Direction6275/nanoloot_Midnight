local Constants = NanoLoot.Globals.Constants

local function GetLootText(lootInfo)
    return lootInfo.classPlayerNoRealm .. "|r > " .. lootInfo.link
end

local function GetPanelWidth()
    return NanoLootDB.FontSize * 24
end

local function ApplyPanelPosition(panel)
    local hasPosition = NanoLootDB.PanelPoint and NanoLootDB.PanelRelativePoint and NanoLootDB.PanelPositionX and
        NanoLootDB.PanelPositionY
    if not hasPosition then
        return
    end

    panel:SetPoint(
        NanoLootDB.PanelPoint,
        UIParent,
        NanoLootDB.PanelRelativePoint,
        NanoLootDB.PanelPositionX,
        NanoLootDB.PanelPositionY
    )
end

local function CreateMainPanel()
    local function onDragStop(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, offsetX, offsetY = self:GetPoint()
        NanoLootDB.PanelPoint = point
        NanoLootDB.PanelRelativePoint = relativePoint
        NanoLootDB.PanelPositionX = offsetX
        NanoLootDB.PanelPositionY = offsetY
    end

    local panel = Elements.Panel.CreatePanel(
        UIParent,
        "NANOLOOT_PANEL_BASE",
        GetPanelWidth(),
        Constants.PANEL_HEIGHT,
        5,
        -5,
        nil,
        nil,
        true,
        "TOPLEFT",
        "TOPLEFT",
        nil,
        true,
        onDragStop
    )
    panel:SetScript("OnDragStop", onDragStop)

    ApplyPanelPosition(panel)

    return panel
end

local function ResolveFontPath()
    if NanoLootDB.CustomFontName and NanoLootDB.CustomFontPath then
        return NanoLootDB.CustomFontPath
    end
    return Constants.FONT_PATH
end

local function CreateTitleBar(parent)
    local fontPath = ResolveFontPath()
    local barHeight = NanoLootDB.FontSize + 12

    local titleBar = Elements.Panel.CreatePanel(
        parent,
        "NANOLOOT_TITLE_BAR",
        GetPanelWidth(),
        barHeight,
        0,
        0,
        nil,
        NanoLootDB.TitleBarBackground,
        false,
        "TOP",
        "TOP"
    )
    Elements.Utilities.AddHighlightAndShadow(titleBar)

    Elements.Text.CreateText(
        fontPath,
        "NANOLOOT_TITLE_BAR_TEXT",
        titleBar,
        titleBar,
        "TOPLEFT",
        barHeight,
        "nanoloot",
        NanoLootDB.FontSize,
        Constants.PADDING,
        -(barHeight / 6),
        "TOPLEFT",
        "NONE"
    )

    local clearAllButton = Elements.Buttons.CreateButton(
        titleBar,
        "NANOLOOT_LOOT_BAR_CLEAR_ALL",
        "Clear",
        45,
        18,
        Constants.FONT_PATH,
        Constants.BUTTONS.SKIP_LABEL,
        0,
        0,
        Constants.BUTTONS.SKIP_BORDER,
        Constants.BUTTONS.SKIP_BG,
        "RIGHT",
        -4,
        0,
        NanoLootDB.FontSize,
        Constants.BUTTONS.SKIP_LABEL_SHADOW,
        Constants.BUTTONS.SKIP_HIGHLIGHT
    )
    clearAllButton:SetScript("OnClick", function(_, motion)
        if not motion then
            return
        end
        NanoLootDB.LootList = {}
        PlaySoundFile([[Interface\Addons\nanoloot\skip.mp3]])
        NanoLoot.UI.RenderLoot()
    end)

    return titleBar
end

local function CreateWaitingBar(parent)
    local fontPath = ResolveFontPath()
    local barHeight = NanoLootDB.FontSize + 12

    local waitingBar = Elements.Panel.CreatePanel(
        parent,
        "NANOLOOT_WAITING_BAR",
        GetPanelWidth(),
        barHeight + 1,
        0,
        1,
        nil,
        Elements.Palette.RGB.DARK_GREY,
        false,
        "TOPLEFT",
        "BOTTOMLEFT",
        1
    )

    Elements.Text.CreateText(
        fontPath,
        "NANOLOOT_WAITING_BAR_TEXT",
        waitingBar,
        waitingBar,
        "TOPLEFT",
        barHeight,
        "|cffa398acWaiting for loot...|r",
        NanoLootDB.FontSize,
        Constants.PADDING,
        -(barHeight / 6),
        "TOPLEFT",
        "NONE",
        { 21 / 255, 19 / 255, 23 / 255 },
        1
    )
end

local function SetMainPanelSize()
    local barHeight = NanoLootDB.FontSize + 12

    if #NanoLootDB.LootList > 0 then
        _G["NANOLOOT_PANEL_BASE"]:SetSize(
            GetPanelWidth(),
            barHeight + (barHeight * #NanoLootDB.LootList)
        )
    end
end

local function CreateLootBar(parent, index, lootInfo)
    local fontPath = ResolveFontPath()
    local barHeight = NanoLootDB.FontSize + 12

    local lootBar = Elements.Panel.CreatePanel(
        parent,
        "NANOLOOT_LOOT_BAR_" .. index,
        GetPanelWidth(),
        barHeight + 1,
        0,
        1,
        nil,
        nil,
        false,
        "TOPLEFT",
        "BOTTOMLEFT",
        1
    )

    local lootBarTextFrame = Elements.Text.CreateText(
        fontPath,
        "NANOLOOT_LOOT_BAR_TEXT_" .. index,
        lootBar,
        lootBar,
        "TOPLEFT",
        barHeight,
        GetLootText(lootInfo),
        NanoLootDB.FontSize,
        Constants.PADDING,
        -(barHeight / 4.5),
        "TOPLEFT",
        "NONE",
        { 21 / 255, 19 / 255, 23 / 255 },
        1
    )
    lootBarTextFrame:SetHyperlinksEnabled(true)
    lootBarTextFrame:SetScript("OnHyperlinkEnter", function(self, data)
        _G["GameTooltip"]:SetOwner(self, "ANCHOR_CURSOR")
        _G["GameTooltip"]:SetHyperlink(data)
        GameTooltip_ShowCompareItem(_G["GameTooltip"])
        _G["GameTooltip"]:Show()
    end)
    lootBarTextFrame:SetScript("OnHyperlinkLeave", function()
        _G["GameTooltip"]:Hide()
    end)

    local skipButton = Elements.Buttons.CreateButton(
        lootBar,
        "NANOLOOT_LOOT_BAR_CLEAR_" .. index,
        "x",
        15,
        14,
        Constants.FONT_PATH,
        Constants.BUTTONS.SKIP_LABEL,
        1,
        2,
        Constants.BUTTONS.SKIP_BORDER,
        Constants.BUTTONS.SKIP_BG,
        "RIGHT",
        -(Constants.PADDING / 2),
        0,
        8,
        Constants.BUTTONS.SKIP_LABEL_SHADOW,
        Constants.BUTTONS.SKIP_HIGHLIGHT
    )
    skipButton:SetScript("OnClick", function(_, motion)
        if not motion then
            return
        end
        table.remove(NanoLootDB.LootList, index)
        PlaySoundFile([[Interface\Addons\nanoloot\skip.mp3]])
        NanoLoot.UI.RenderLoot()
    end)

    local messageButton = Elements.Buttons.CreateButton(
        lootBar,
        "NANOLOOT_LOOT_BAR_MSG_" .. index,
        "@",
        15,
        14,
        Constants.FONT_PATH,
        Constants.BUTTONS.MSG_LABEL,
        0,
        2,
        Constants.BUTTONS.MSG_BORDER,
        Constants.BUTTONS.MSG_BG,
        "RIGHT",
        -(skipButton:GetWidth() + 4),
        0,
        8,
        Constants.BUTTONS.MSG_LABEL_SHADOW,
        Constants.BUTTONS.MSG_HIGHLIGHT
    )
    messageButton:SetPoint("TOPRIGHT", skipButton, "TOPLEFT", -3, 0)
    messageButton:SetScript("OnClick", function(_, motion)
        if not motion then
            return
        end
        NanoLoot.Utilities.SendLootChatMessage(lootInfo)
        PlaySoundFile([[Interface\Addons\nanoloot\send_message.mp3]])
    end)
end

local function UpdateLootBar(index, lootInfo)
    local lootBar = _G["NANOLOOT_LOOT_BAR_" .. index]
    lootBar:Hide()
    _G["NANOLOOT_LOOT_BAR_TEXT_" .. index]:SetText(GetLootText(lootInfo))

    _G["NANOLOOT_LOOT_BAR_MSG_" .. index]:SetScript("OnClick", function(_, motion)
        if not motion then
            return
        end
        NanoLoot.Utilities.SendLootChatMessage(lootInfo)
        PlaySoundFile([[Interface\Addons\nanoloot\send_message.mp3]])
    end)

    _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index]:SetScript("OnClick", function(_, motion)
        if not motion then
            return
        end
        table.remove(NanoLootDB.LootList, index)
        PlaySoundFile([[Interface\Addons\nanoloot\skip.mp3]])
        NanoLoot.UI.RenderLoot()
    end)

    lootBar:Show()
end

local function UpdateFontStrings(fontPath)
    fontPath = fontPath or ResolveFontPath()

    local barHeight = NanoLootDB.FontSize + 12
    local barWidth = GetPanelWidth()

    _G["NANOLOOT_PANEL_BASE"]:SetWidth(barWidth)

    _G["NANOLOOT_TITLE_BAR"]:SetSize(barWidth, barHeight)
    _G["NANOLOOT_TITLE_BAR_INNER_BORDER"]:SetSize((barWidth - 2), 1)
    _G["NANOLOOT_TITLE_BAR_SHADOW_BORDER"]:SetSize((barWidth - 2), 1)
    _G["NANOLOOT_TITLE_BAR_TEXT"]:SetFont(fontPath, NanoLootDB.FontSize)

    local buttonFontSize = NanoLootDB.FontSize * 0.85
    local additional = (NanoLootDB.FontSize * 0.5)

    if NanoLootDB.FontSize < 19 then
        buttonFontSize = NanoLootDB.FontSize
        additional = (NanoLootDB.FontSize * 0.35)
    end

    local clearAllButtonWidth = 45 + additional
    local clearAllButtonHeight = 14 + additional

    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL"]:SetSize(clearAllButtonWidth, clearAllButtonHeight)
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL_TEXT"]:SetFont(fontPath, buttonFontSize)
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL_INNER_BORDER"]:SetSize((clearAllButtonWidth - 2), 1)
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL_SHADOW_BORDER"]:SetSize((clearAllButtonWidth - 2), 1)

    _G["NANOLOOT_WAITING_BAR"]:SetSize(barWidth, barHeight)
    _G["NANOLOOT_WAITING_BAR_TEXT"]:SetFont(fontPath, NanoLootDB.FontSize)

    if #NanoLootDB.LootList > 0 then
        for index = 1, #NanoLootDB.LootList do
            _G["NANOLOOT_LOOT_BAR_" .. index]:SetSize(barWidth, barHeight)
            _G["NANOLOOT_LOOT_BAR_TEXT_" .. index]:SetFont(fontPath, NanoLootDB.FontSize)

            local barButtonFont = NanoLootDB.FontSize * 0.85
            if NanoLootDB.FontSize < 18 then
                barButtonFont = NanoLootDB.FontSize
            end

            local additionalBar = (NanoLootDB.FontSize / 3)
            local clearButtonWidth = 15 + additionalBar
            local clearButtonHeight = 14 + additionalBar
            local messageButtonWidth = 15 + additionalBar
            local messageButtonHeight = 14 + additionalBar

            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index]:SetSize(clearButtonWidth, clearButtonHeight)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_TEXT"]:SetFont(fontPath, barButtonFont)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_INNER_BORDER"]:SetSize((clearButtonWidth - 2), 1)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_SHADOW_BORDER"]:SetSize((clearButtonWidth - 2), 1)

            _G["NANOLOOT_LOOT_BAR_MSG_" .. index]:SetSize(messageButtonWidth, messageButtonHeight)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_TEXT"]:SetFont(fontPath, barButtonFont)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_INNER_BORDER"]:SetSize((messageButtonWidth - 2), 1)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_SHADOW_BORDER"]:SetSize((messageButtonWidth - 2), 1)
        end
    end
end

local function RenderLoot()
    local parent = _G["NANOLOOT_TITLE_BAR"]

    for i = 1, Constants.LOOTLIST_LIMIT do
        local bar = _G["NANOLOOT_LOOT_BAR_" .. i]
        if bar then
            bar:Hide()
        end
    end

    if #NanoLootDB.LootList == 0 then
        _G["NANOLOOT_WAITING_BAR"]:Show()

        if NanoLootDB.HideWhenEmpty then
            _G["NANOLOOT_PANEL_BASE"]:Hide()
        end
    else
        _G["NANOLOOT_WAITING_BAR"]:Hide()
        _G["NANOLOOT_PANEL_BASE"]:Show()

        for index, value in ipairs(NanoLootDB.LootList) do
            if _G["NANOLOOT_LOOT_BAR_" .. index] then
                UpdateLootBar(index, value)
            elseif index == 1 then
                CreateLootBar(parent, index, value)
            else
                CreateLootBar(_G["NANOLOOT_LOOT_BAR_" .. index - 1], index, value)
            end
        end
    end

    SetMainPanelSize()
    UpdateFontStrings()
end

NanoLoot.UI = {
    CreateMainPanel = CreateMainPanel,
    CreateTitleBar = CreateTitleBar,
    CreateWaitingBar = CreateWaitingBar,
    SetMainPanelSize = SetMainPanelSize,
    RenderLoot = RenderLoot,
    UpdateFontStrings = UpdateFontStrings
}
