local Config = {}

local function ApplyTitleBarColor()
    _G["NANOLOOT_TITLE_BAR"]:SetBackdropColor(unpack({
        NanoLootDB.TitleBarBackground[1],
        NanoLootDB.TitleBarBackground[2],
        NanoLootDB.TitleBarBackground[3]
    }))
end

local function ColorCallback(restore)
    local newR, newG, newB
    if restore then
        newR, newG, newB = unpack(restore)
    else
        newR, newG, newB = ColorPickerFrame:GetColorRGB()
    end

    NanoLootDB.TitleBarBackground = { newR, newG, newB }
    ApplyTitleBarColor()
end

local function ShowColorPicker(r, g, b, changedCallback)
    ColorPickerFrame.previousValues = { r, g, b }
    ColorPickerFrame.func = changedCallback
    ColorPickerFrame.cancelFunc = changedCallback
    ColorPickerFrame:SetColorRGB(r, g, b)
    ColorPickerFrame:Hide()
    ColorPickerFrame:Show()
end

local function GetCurrentClassColour()
    local _, class = UnitClass("player")
    return class and C_ClassColor.GetClassColor(class)
end

local function HandleClassColourClick()
    local colourPickerButton = _G["NANOLOOT_TITLEBAR_BG_COLOR_PICKER"]

    if NanoLootDB.UseClassColour then
        local currentClassColour = GetCurrentClassColour()
        if currentClassColour then
            NanoLootDB.TitleBarBackground = { currentClassColour.r, currentClassColour.g, currentClassColour.b }
        end
        colourPickerButton:Disable()
    else
        colourPickerButton:Enable()
    end

    ApplyTitleBarColor()
end

local function CreateConfigFrame()
    local categoryName = "nanoloot |Tinterface/cursor/crosshair/lootall:18:18:0:0|t"
    local configFrame = CreateFrame("Frame", "NANOLOOT_CONFIG_FRAME", UIParent, "BackdropTemplate")

    local headerText = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
    headerText:SetPoint("TOPLEFT", 10, -10)
    headerText:SetText(NanoLoot.Globals.Logo)

    local appearanceText = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    appearanceText:SetPoint("TOPLEFT", headerText, "BOTTOMLEFT", 0, -20)
    appearanceText:SetText("Appearance")

    local classColourCheckbox = CreateFrame(
        "CheckButton",
        "NANOLOOT_CLASS_COLOUR_CHECKBOX",
        configFrame,
        "SettingsCheckBoxTemplate"
    )
    classColourCheckbox:SetPoint("TOPLEFT", appearanceText, "BOTTOMLEFT", 0, -10)

    classColourCheckbox.text = classColourCheckbox:CreateFontString(
        "NANOLOOT_CLASS_COLOUR_CHECKBOX_TEXT",
        "ARTWORK",
        "GameFontNormal"
    )
    classColourCheckbox.text:SetText("Use class colour")
    classColourCheckbox.text:SetPoint("LEFT", classColourCheckbox, "RIGHT", 4, 0)
    classColourCheckbox:SetChecked(NanoLootDB.UseClassColour)
    classColourCheckbox:SetScript("OnClick", function()
        NanoLootDB.UseClassColour = not NanoLootDB.UseClassColour
        classColourCheckbox:SetChecked(NanoLootDB.UseClassColour)
        HandleClassColourClick()

        if NanoLootDB.UseClassColour then
            _G["NANOLOOT_TITLEBAR_BG_COLOR_PICKER"]:Hide()
        else
            _G["NANOLOOT_TITLEBAR_BG_COLOR_PICKER"]:Show()
        end
    end)

    local colourPickerButton = CreateFrame(
        "Button",
        "NANOLOOT_TITLEBAR_BG_COLOR_PICKER",
        configFrame,
        "UIPanelButtonTemplate"
    )
    colourPickerButton:SetText("Custom")
    colourPickerButton:SetWidth(120)
    colourPickerButton:SetPoint("LEFT", classColourCheckbox.text, "TOPRIGHT", 10, -10)
    colourPickerButton:SetScript("OnClick", function()
        ShowColorPicker(
            NanoLootDB.TitleBarBackground[1],
            NanoLootDB.TitleBarBackground[2],
            NanoLootDB.TitleBarBackground[3],
            ColorCallback
        )
    end)

    if NanoLootDB.UseClassColour then
        _G["NANOLOOT_TITLEBAR_BG_COLOR_PICKER"]:Hide()
    else
        _G["NANOLOOT_TITLEBAR_BG_COLOR_PICKER"]:Show()
    end

    HandleClassColourClick()

    local customFontCheckbox = CreateFrame(
        "CheckButton",
        "NANOLOOT_CUSTOM_FONT_CHECKBOX",
        configFrame,
        "SettingsCheckBoxTemplate"
    )
    customFontCheckbox:SetPoint("TOPLEFT", classColourCheckbox, "BOTTOMLEFT", 0, -10)

    local lsmFontNames = NanoLoot.Globals.LSM and NanoLoot.Globals.LSM:List("font") or {}
    local lsmFontPaths = NanoLoot.Globals.LSM and NanoLoot.Globals.LSM:HashTable("font") or {}

    customFontCheckbox.text = customFontCheckbox:CreateFontString(
        "NANOLOOT_CUSTOM_FONT_CHECKBOX_TEXT",
        "ARTWORK",
        "GameFontNormal"
    )
    customFontCheckbox.text:SetText("Use custom font")
    customFontCheckbox.text:SetPoint("LEFT", customFontCheckbox, "RIGHT", 4, 0)
    customFontCheckbox:SetChecked(NanoLootDB.UseCustomFont)
    customFontCheckbox:SetScript("OnClick", function()
        NanoLootDB.UseCustomFont = not NanoLootDB.UseCustomFont
        customFontCheckbox:SetChecked(NanoLootDB.UseCustomFont)

        if NanoLootDB.UseCustomFont then
            _G["NANOLOOT_CUSTOM_FONT_DROPDOWN"]:Show()
            _G["NANOLOOT_CUSTOM_FONT_DROPDOWN"]:SetText(lsmFontNames[1])
            NanoLootDB.CustomFontName = lsmFontNames[1]
            NanoLootDB.CustomFontPath = lsmFontPaths[lsmFontNames[1]]
            NanoLoot.UI.UpdateFontStrings()
        else
            _G["NANOLOOT_CUSTOM_FONT_DROPDOWN"]:Hide()
            _G["NANOLOOT_CUSTOM_FONT_DROPDOWN"]:SetText("")
            NanoLootDB.CustomFontName = nil
            NanoLootDB.CustomFontPath = nil
            NanoLoot.UI.UpdateFontStrings(NanoLoot.Globals.Media.FontPath)
        end
    end)

    configFrame:SetScript("OnShow", function()
        if _G["NANOLOOT_CUSTOM_FONT_DROPDOWN"] then
            return
        end

        local customFontDropdown = CreateFrame(
            "Button",
            "NANOLOOT_CUSTOM_FONT_DROPDOWN",
            configFrame,
            "NanoLootWidgetsDropDownTemplate"
        )
        customFontDropdown:SetPoint("LEFT", customFontCheckbox.text, "TOPRIGHT", 10, -10)
        customFontDropdown:SetText(NanoLootDB.CustomFontName or lsmFontNames[1])
        customFontDropdown:SetNormalAtlas('friendslist-categorybutton')
        customFontDropdown:SetHighlightAtlas('friendslist-categorybutton')
        customFontDropdown:SetSize(293, 23)

        local options = {}
        for _, value in pairs(lsmFontNames) do
            table.insert(options, {
                text = value,
                func = function()
                    NanoLootDB.CustomFontName = value
                    NanoLootDB.CustomFontPath = lsmFontPaths[value]
                    _G["NANOLOOT_CUSTOM_FONT_DROPDOWN"]:SetText(value)
                    NanoLoot.UI.UpdateFontStrings()
                end,
                fontPath = lsmFontPaths[value]
            })
        end
        customFontDropdown:SetMenu(options)

        if NanoLootDB.UseCustomFont then
            customFontDropdown:Show()

            if not NanoLootDB.CustomFontName then
                NanoLootDB.CustomFontName = lsmFontNames[1]
                NanoLootDB.CustomFontPath = lsmFontPaths[lsmFontNames[1]]
                NanoLoot.UI.UpdateFontStrings()
            end
        else
            customFontDropdown:Hide()
        end
    end)

    local function OnValueChanged(_, value)
        NanoLootDB.FontSize = value
        NanoLoot.UI.UpdateFontStrings()
    end

    local formatters = {}
    local top = MinimalSliderWithSteppersMixin.Label.Top
    local right = MinimalSliderWithSteppersMixin.Label.Right
    formatters[right] = CreateMinimalSliderFormatter(right, function(value)
        return value
    end)
    formatters[top] = CreateMinimalSliderFormatter(top, function()
        return 'Font size'
    end)

    local fontSizeSlider = CreateFrame(
        "Slider",
        "NANOLOOT_FONT_SIZE_SLIDER",
        configFrame,
        "MinimalSliderWithSteppersTemplate"
    )
    fontSizeSlider:SetPoint("BOTTOMLEFT", customFontCheckbox, "BOTTOMLEFT", 0, -60)
    fontSizeSlider:Init(NanoLootDB.FontSize or 8, 12, 24, 12, formatters)
    fontSizeSlider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, OnValueChanged)
    fontSizeSlider:SetObeyStepOnDrag(false)

    local visibilityText = configFrame:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    visibilityText:SetPoint("BOTTOMLEFT", fontSizeSlider, "BOTTOMLEFT", 0, -30)
    visibilityText:SetText("Visibility")

    local hideWhenEmptyCheckbox = CreateFrame(
        "CheckButton",
        "NANOLOOT_HIDE_WHEN_EMPTY_CHECKBOX",
        configFrame,
        "SettingsCheckBoxTemplate"
    )
    hideWhenEmptyCheckbox:SetPoint("TOPLEFT", visibilityText, "BOTTOMLEFT", 0, -10)

    hideWhenEmptyCheckbox.text = hideWhenEmptyCheckbox:CreateFontString(
        "NANOLOOT_HIDE_WHEN_EMPTY_CHECKBOX_TEXT",
        "ARTWORK",
        "GameFontNormal"
    )
    hideWhenEmptyCheckbox.text:SetText("Hide when empty")
    hideWhenEmptyCheckbox.text:SetPoint("LEFT", hideWhenEmptyCheckbox, "RIGHT", 4, 0)
    hideWhenEmptyCheckbox:SetChecked(NanoLootDB.HideWhenEmpty)
    hideWhenEmptyCheckbox:SetScript("OnClick", function()
        NanoLootDB.HideWhenEmpty = not NanoLootDB.HideWhenEmpty
        hideWhenEmptyCheckbox:SetChecked(NanoLootDB.HideWhenEmpty)
        if NanoLootDB.HideWhenEmpty then
            _G["NANOLOOT_PANEL_BASE"]:Hide()
        else
            _G["NANOLOOT_PANEL_BASE"]:Show()
        end
    end)

    local category = Settings.RegisterCanvasLayoutCategory(configFrame, categoryName)
    Settings.RegisterAddOnCategory(category)
end

Config.CreateConfigFrame = CreateConfigFrame

NanoLoot.Config = Config
