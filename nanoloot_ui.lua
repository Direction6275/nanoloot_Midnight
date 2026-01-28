local function GetLootText(lootInfo)
    local lootText = lootInfo.classPlayerNoRealm .. "|r > " .. lootInfo.link
    return lootText
end

local function GetPanelWidth()
    return NanoLootDB.FontSize * 24
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

    local NanoLootPanel = Elements.Panel.CreatePanel(
        UIParent,
        "NANOLOOT_PANEL_BASE",
        GetPanelWidth(),
        NanoLoot.Globals.NANOLOOT_PANEL_HEIGHT,
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
    NanoLootPanel:SetScript("OnDragStop", onDragStop)

    local panelPosition = NanoLootDB.PanelPoint and NanoLootDB.PanelRelativePoint and NanoLootDB.PanelPositionX and
        NanoLootDB.PanelPositionY

    if panelPosition then
        NanoLootPanel:SetPoint(
            NanoLootDB.PanelPoint,
            UIParent,
            NanoLootDB.PanelRelativePoint,
            NanoLootDB.PanelPositionX,
            NanoLootDB.PanelPositionY
        )
    end

    return NanoLootPanel
end

local function CreateTitleBar(parent)
    local fontPath = NanoLoot.Globals.NANOLOOT_FONT_PATH
    local barHeight = NanoLootDB.FontSize + 12

    if NanoLootDB.CustomFontName and NanoLootDB.CustomFontPath then
        fontPath = NanoLootDB.CustomFontPath
    end

    local NanoLootTitleBar = Elements.Panel.CreatePanel(
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
    Elements.Utilities.AddHighlightAndShadow(NanoLootTitleBar)

    Elements.Text.CreateText(
        fontPath,
        "NANOLOOT_TITLE_BAR_TEXT",
        NanoLootTitleBar,
        NanoLootTitleBar,
        "TOPLEFT",
        barHeight,
        "nanoloot",
        NanoLootDB.FontSize,
        NanoLoot.Globals.NANOLOOT_PADDING,
        -(barHeight / 6),
        "TOPLEFT",
        "NONE"
    )

    local clearAllButton = Elements.Buttons.CreateButton(
        NanoLootTitleBar,
        "NANOLOOT_LOOT_BAR_CLEAR_ALL",
        "Clear",
        45,
        18,
        NanoLoot.Globals.NANOLOOT_FONT_PATH,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_LABEL,
        0,
        0,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_BORDER,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_BG,
        "RIGHT",
        -4,
        0,
        NanoLootDB.FontSize,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_LABEL_SHADOW,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_HIGHLIGHT
    )
    clearAllButton:SetScript("OnClick", function(_, motion)
        if not motion then return end
        NanoLootDB.LootList = {}
        PlaySoundFile([[Interface\Addons\nanoloot_Midnight\skip.mp3]])
        NanoLoot.UI.RenderLoot()
    end)

    return NanoLootTitleBar
end

local function CreateWaitingBar(parent)
    local fontPath = NanoLoot.Globals.NANOLOOT_FONT_PATH
    local barHeight = NanoLootDB.FontSize + 12

    if NanoLootDB.CustomFontName and NanoLootDB.CustomFontPath then
        fontPath = NanoLootDB.CustomFontPath
    end

    local NanoLootWaitingBar = Elements.Panel.CreatePanel(parent,
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
        NanoLootWaitingBar,
        NanoLootWaitingBar,
        "TOPLEFT",
        barHeight,
        "|cffa398acWaiting for loot...|r",
        NanoLootDB.FontSize,
        NanoLoot.Globals.NANOLOOT_PADDING,
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
    local fontPath = NanoLoot.Globals.NANOLOOT_FONT_PATH
    local barHeight = NanoLootDB.FontSize + 12

    if NanoLootDB.CustomFontName and NanoLootDB.CustomFontPath then
        fontPath = NanoLootDB.CustomFontPath
    end

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

    local lootBarTextFrame, _ = Elements.Text.CreateText(
        fontPath,
        "NANOLOOT_LOOT_BAR_TEXT_" .. index,
        lootBar,
        lootBar,
        "TOPLEFT",
        barHeight,
        GetLootText(lootInfo),
        NanoLootDB.FontSize,
        NanoLoot.Globals.NANOLOOT_PADDING,
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
    lootBarTextFrame:SetScript("OnHyperlinkLeave", function(self, data)
        _G["GameTooltip"]:Hide()
    end)

    local skipButton = Elements.Buttons.CreateButton(
        lootBar,
        "NANOLOOT_LOOT_BAR_CLEAR_" .. index,
        "x",
        15,
        14,
        NanoLoot.Globals.NANOLOOT_FONT_PATH,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_LABEL,
        1,
        2,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_BORDER,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_BG,
        "RIGHT",
        -(NanoLoot.Globals.NANOLOOT_PADDING / 2),
        0,
        8,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_LABEL_SHADOW,
        NanoLoot.Globals.Buttons.NANOLOOT_SKIP_BUTTON_HIGHLIGHT
    )
    skipButton:SetScript("OnClick", function(_, motion)
        if not motion then return end
        table.remove(NanoLootDB.LootList, index)
        PlaySoundFile([[Interface\Addons\nanoloot_Midnight\skip.mp3]])
        NanoLoot.UI.RenderLoot()
    end)

    local messageButton = Elements.Buttons.CreateButton(
        lootBar,
        "NANOLOOT_LOOT_BAR_MSG_" .. index,
        "@",
        15,
        14,
        NanoLoot.Globals.NANOLOOT_FONT_PATH,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_LABEL,
        0,
        2,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_BORDER,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_BG,
        "RIGHT",
        -(skipButton:GetWidth() + 4),
        0,
        8,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_LABEL_SHADOW,
        NanoLoot.Globals.Buttons.NANOLOOT_MSG_BUTTON_HIGHLIGHT
    )
    messageButton:SetPoint("TOPRIGHT", skipButton, "TOPLEFT", -3, 0)
    messageButton:SetScript("OnClick", function(_, motion)
        if not motion then return end
        NanoLoot.Utilities.SendLootChatMessage(lootInfo)
        PlaySoundFile([[Interface\Addons\nanoloot_Midnight\send_message.mp3]])
    end)
end

local function UpdateLootBar(index, lootInfo)
    _G["NANOLOOT_LOOT_BAR_" .. index]:Hide()
    _G["NANOLOOT_LOOT_BAR_TEXT_" .. index]:SetText(GetLootText(lootInfo))

    _G["NANOLOOT_LOOT_BAR_MSG_" .. index]:SetScript("OnClick", function(_, motion)
        if not motion then return end
        NanoLoot.Utilities.SendLootChatMessage(lootInfo)
        PlaySoundFile([[Interface\Addons\nanoloot_Midnight\send_message.mp3]])
    end)

    _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index]:SetScript("OnClick", function(_, motion)
        if not motion then return end
        table.remove(NanoLootDB.LootList, index)
        PlaySoundFile([[Interface\Addons\nanoloot_Midnight\skip.mp3]])
        NanoLoot.UI.RenderLoot()
    end)

    _G["NANOLOOT_LOOT_BAR_" .. index]:Show()
end

local function UpdateFontStrings(fontPath)
    fontPath = fontPath or NanoLootDB.CustomFontPath or NanoLoot.Globals.NANOLOOT_FONT_PATH

    local barHeight = NanoLootDB.FontSize + 12
    local barWidth = GetPanelWidth()

    -- Main panel
    _G["NANOLOOT_PANEL_BASE"]:SetWidth(barWidth)

    -- Title bar
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
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL" .. "_TEXT"]:SetFont(fontPath, buttonFontSize)
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL" .. "_INNER_BORDER"]:SetSize((clearAllButtonWidth - 2), 1)
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL" .. "_SHADOW_BORDER"]:SetSize((clearAllButtonWidth - 2), 1)

    -- Waiting bar
    _G["NANOLOOT_WAITING_BAR"]:SetSize(barWidth, barHeight)
    _G["NANOLOOT_WAITING_BAR_TEXT"]:SetFont(fontPath, NanoLootDB.FontSize)

    -- Loot list
    if #NanoLootDB.LootList > 0 then
        for index, _ in ipairs(NanoLootDB.LootList) do
            _G["NANOLOOT_LOOT_BAR_" .. index]:SetSize(barWidth, barHeight)
            _G["NANOLOOT_LOOT_BAR_TEXT_" .. index]:SetFont(fontPath, NanoLootDB.FontSize)

            -- -- Buttons
            local buttonFontSize = NanoLootDB.FontSize * 0.85
            if NanoLootDB.FontSize < 18 then
                buttonFontSize = NanoLootDB.FontSize
            end

            local additional = (NanoLootDB.FontSize / 3)
            local clearButtonWidth = 15 + additional
            local clearButtonHeight = 14 + additional
            local messageButtonWidth = 15 + additional
            local messageButtonHeight = 14 + additional

            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index]:SetSize(clearButtonWidth, clearButtonHeight)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_TEXT"]:SetFont(fontPath, buttonFontSize)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_INNER_BORDER"]:SetSize((clearButtonWidth - 2), 1)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_SHADOW_BORDER"]:SetSize((clearButtonWidth - 2), 1)

            _G["NANOLOOT_LOOT_BAR_MSG_" .. index]:SetSize(messageButtonWidth, messageButtonHeight)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_TEXT"]:SetFont(fontPath, buttonFontSize)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_INNER_BORDER"]:SetSize((messageButtonWidth - 2), 1)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_SHADOW_BORDER"]:SetSize((messageButtonWidth - 2), 1)
        end
    end
end

local function RenderLoot()
    local parent = _G["NANOLOOT_TITLE_BAR"]

    for i = 1, NanoLoot.Globals.NANOLOOT_LOOTLIST_LIMIT, 1 do
        if _G["NANOLOOT_LOOT_BAR_" .. i] then
            _G["NANOLOOT_LOOT_BAR_" .. i]:Hide();
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
            else
                if index == 1 then
                    CreateLootBar(parent, index, value)
                else
                    CreateLootBar(_G["NANOLOOT_LOOT_BAR_" .. index - 1], index, value)
                end
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
