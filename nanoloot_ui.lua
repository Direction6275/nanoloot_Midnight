local UI = {}
UI.frames = {}

local function GetPanelWidth()
    return NanoLootDB.FontSize * 24
end

local function GetBarHeight()
    return NanoLootDB.FontSize + 12
end

local function GetFontPath()
    if NanoLootDB.CustomFontName and NanoLootDB.CustomFontPath then
        return NanoLootDB.CustomFontPath
    end
    return NanoLoot.Globals.Media.FontPath
end

local function GetLootText(lootInfo)
    return lootInfo.classPlayerNoRealm .. "|r > " .. lootInfo.link
end

local function StorePanelPosition(panel)
    local point, _, relativePoint, offsetX, offsetY = panel:GetPoint()
    NanoLootDB.PanelPoint = point
    NanoLootDB.PanelRelativePoint = relativePoint
    NanoLootDB.PanelPositionX = offsetX
    NanoLootDB.PanelPositionY = offsetY
end

local function CreateMainPanel()
    local panel = Elements.Panel.CreatePanel(
        UIParent,
        "NANOLOOT_PANEL_BASE",
        GetPanelWidth(),
        NanoLoot.Globals.Layout.PanelHeight,
        5,
        -5,
        nil,
        nil,
        true,
        "TOPLEFT",
        "TOPLEFT",
        nil,
        true,
        StorePanelPosition
    )

    panel:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        StorePanelPosition(self)
    end)

    if NanoLootDB.PanelPoint and NanoLootDB.PanelRelativePoint and NanoLootDB.PanelPositionX and NanoLootDB.PanelPositionY then
        panel:SetPoint(
            NanoLootDB.PanelPoint,
            UIParent,
            NanoLootDB.PanelRelativePoint,
            NanoLootDB.PanelPositionX,
            NanoLootDB.PanelPositionY
        )
    end

    UI.frames.panel = panel
    return panel
end

local function CreateTitleBar(parent)
    local barHeight = GetBarHeight()
    local fontPath = GetFontPath()

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
        NanoLoot.Globals.Layout.Padding,
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
        NanoLoot.Globals.Media.FontPath,
        NanoLoot.Globals.Buttons.Skip.Label,
        0,
        0,
        NanoLoot.Globals.Buttons.Skip.Border,
        NanoLoot.Globals.Buttons.Skip.Background,
        "RIGHT",
        -4,
        0,
        NanoLootDB.FontSize,
        NanoLoot.Globals.Buttons.Skip.LabelShadow,
        NanoLoot.Globals.Buttons.Skip.Highlight
    )
    clearAllButton:SetScript("OnClick", function(_, motion)
        if not motion then
            return
        end
        NanoLootDB.LootList = {}
        PlaySoundFile([[Interface\Addons\nanoloot\skip.mp3]])
        UI.RenderLoot()
    end)

    UI.frames.titleBar = titleBar
    return titleBar
end

local function CreateWaitingBar(parent)
    local barHeight = GetBarHeight()
    local fontPath = GetFontPath()

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
        NanoLoot.Globals.Layout.Padding,
        -(barHeight / 6),
        "TOPLEFT",
        "NONE",
        { 21 / 255, 19 / 255, 23 / 255 },
        1
    )

    UI.frames.waitingBar = waitingBar
    return waitingBar
end

local function CreateLootBar(parent, index, lootInfo)
    local barHeight = GetBarHeight()
    local fontPath = GetFontPath()

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
        NanoLoot.Globals.Layout.Padding,
        -(barHeight / 4.5),
        "TOPLEFT",
        "NONE",
        { 21 / 255, 19 / 255, 23 / 255 },
        1
    )
    lootBarTextFrame:SetHyperlinksEnabled(true)
    lootBarTextFrame:SetScript("OnHyperlinkEnter", function(self, data)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
        GameTooltip:SetHyperlink(data)
        GameTooltip_ShowCompareItem(GameTooltip)
        GameTooltip:Show()
    end)
    lootBarTextFrame:SetScript("OnHyperlinkLeave", function()
        GameTooltip:Hide()
    end)

    local skipButton = Elements.Buttons.CreateButton(
        lootBar,
        "NANOLOOT_LOOT_BAR_CLEAR_" .. index,
        "x",
        15,
        14,
        NanoLoot.Globals.Media.FontPath,
        NanoLoot.Globals.Buttons.Skip.Label,
        1,
        2,
        NanoLoot.Globals.Buttons.Skip.Border,
        NanoLoot.Globals.Buttons.Skip.Background,
        "RIGHT",
        -(NanoLoot.Globals.Layout.Padding / 2),
        0,
        8,
        NanoLoot.Globals.Buttons.Skip.LabelShadow,
        NanoLoot.Globals.Buttons.Skip.Highlight
    )
    skipButton:SetScript("OnClick", function(_, motion)
        if not motion then
            return
        end
        table.remove(NanoLootDB.LootList, index)
        PlaySoundFile([[Interface\Addons\nanoloot\skip.mp3]])
        UI.RenderLoot()
    end)

    local messageButton = Elements.Buttons.CreateButton(
        lootBar,
        "NANOLOOT_LOOT_BAR_MSG_" .. index,
        "@",
        15,
        14,
        NanoLoot.Globals.Media.FontPath,
        NanoLoot.Globals.Buttons.Message.Label,
        0,
        2,
        NanoLoot.Globals.Buttons.Message.Border,
        NanoLoot.Globals.Buttons.Message.Background,
        "RIGHT",
        -(skipButton:GetWidth() + 4),
        0,
        8,
        NanoLoot.Globals.Buttons.Message.LabelShadow,
        NanoLoot.Globals.Buttons.Message.Highlight
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
    local bar = _G["NANOLOOT_LOOT_BAR_" .. index]
    bar:Hide()
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
        UI.RenderLoot()
    end)

    bar:Show()
end

local function UpdateFontStrings(fontPath)
    local barHeight = GetBarHeight()
    local barWidth = GetPanelWidth()
    local resolvedFontPath = fontPath or GetFontPath()

    UI.frames.panel:SetWidth(barWidth)

    _G["NANOLOOT_TITLE_BAR"]:SetSize(barWidth, barHeight)
    _G["NANOLOOT_TITLE_BAR_INNER_BORDER"]:SetSize((barWidth - 2), 1)
    _G["NANOLOOT_TITLE_BAR_SHADOW_BORDER"]:SetSize((barWidth - 2), 1)
    _G["NANOLOOT_TITLE_BAR_TEXT"]:SetFont(resolvedFontPath, NanoLootDB.FontSize)

    local buttonFontSize = NanoLootDB.FontSize * 0.85
    local additional = (NanoLootDB.FontSize * 0.5)
    if NanoLootDB.FontSize < 19 then
        buttonFontSize = NanoLootDB.FontSize
        additional = (NanoLootDB.FontSize * 0.35)
    end

    local clearAllButtonWidth = 45 + additional
    local clearAllButtonHeight = 14 + additional

    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL"]:SetSize(clearAllButtonWidth, clearAllButtonHeight)
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL_TEXT"]:SetFont(resolvedFontPath, buttonFontSize)
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL_INNER_BORDER"]:SetSize((clearAllButtonWidth - 2), 1)
    _G["NANOLOOT_LOOT_BAR_CLEAR_ALL_SHADOW_BORDER"]:SetSize((clearAllButtonWidth - 2), 1)

    _G["NANOLOOT_WAITING_BAR"]:SetSize(barWidth, barHeight)
    _G["NANOLOOT_WAITING_BAR_TEXT"]:SetFont(resolvedFontPath, NanoLootDB.FontSize)

    if #NanoLootDB.LootList > 0 then
        for index, _ in ipairs(NanoLootDB.LootList) do
            _G["NANOLOOT_LOOT_BAR_" .. index]:SetSize(barWidth, barHeight)
            _G["NANOLOOT_LOOT_BAR_TEXT_" .. index]:SetFont(resolvedFontPath, NanoLootDB.FontSize)

            local lootButtonFontSize = NanoLootDB.FontSize * 0.85
            if NanoLootDB.FontSize < 18 then
                lootButtonFontSize = NanoLootDB.FontSize
            end

            local additionalSize = (NanoLootDB.FontSize / 3)
            local clearButtonWidth = 15 + additionalSize
            local clearButtonHeight = 14 + additionalSize
            local messageButtonWidth = 15 + additionalSize
            local messageButtonHeight = 14 + additionalSize

            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index]:SetSize(clearButtonWidth, clearButtonHeight)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_TEXT"]:SetFont(resolvedFontPath, lootButtonFontSize)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_INNER_BORDER"]:SetSize((clearButtonWidth - 2), 1)
            _G["NANOLOOT_LOOT_BAR_CLEAR_" .. index .. "_SHADOW_BORDER"]:SetSize((clearButtonWidth - 2), 1)

            _G["NANOLOOT_LOOT_BAR_MSG_" .. index]:SetSize(messageButtonWidth, messageButtonHeight)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_TEXT"]:SetFont(resolvedFontPath, lootButtonFontSize)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_INNER_BORDER"]:SetSize((messageButtonWidth - 2), 1)
            _G["NANOLOOT_LOOT_BAR_MSG_" .. index .. "_SHADOW_BORDER"]:SetSize((messageButtonWidth - 2), 1)
        end
    end
end

local function SetMainPanelSize()
    if #NanoLootDB.LootList > 0 then
        local barHeight = GetBarHeight()
        UI.frames.panel:SetSize(
            GetPanelWidth(),
            barHeight + (barHeight * #NanoLootDB.LootList)
        )
    end
end

function UI.RenderLoot()
    local parent = _G["NANOLOOT_TITLE_BAR"]

    for i = 1, NanoLoot.Globals.Layout.LootListLimit do
        if _G["NANOLOOT_LOOT_BAR_" .. i] then
            _G["NANOLOOT_LOOT_BAR_" .. i]:Hide()
        end
    end

    if #NanoLootDB.LootList == 0 then
        _G["NANOLOOT_WAITING_BAR"]:Show()

        if NanoLootDB.HideWhenEmpty then
            UI.frames.panel:Hide()
        end
    else
        _G["NANOLOOT_WAITING_BAR"]:Hide()
        UI.frames.panel:Show()

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

function UI.Initialize()
    local panel = CreateMainPanel()
    local titleBar = CreateTitleBar(panel)
    CreateWaitingBar(titleBar)
    UI.RenderLoot()
end

UI.UpdateFontStrings = UpdateFontStrings
UI.SetMainPanelSize = SetMainPanelSize

NanoLoot.UI = UI
