local function ApplyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {}
                ApplyDefaults(target[key], value)
            else
                target[key] = value
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            ApplyDefaults(target[key], value)
        end
    end
end

local function InitializeDatabase()
    NanoLootDB = NanoLootDB or {}
    ApplyDefaults(NanoLootDB, NanoLoot.Defaults)

    if not NanoLootDB.LootList then
        NanoLootDB.LootList = {}
    end
end

local function ShouldHandleLoot(lootInfo)
    local inInstance, instanceType = IsInInstance()
    local inDungeonOrRaid = instanceType == "party" or instanceType == "raid"
    local listNotAtMax = #NanoLootDB.LootList ~= NanoLoot.Globals.Layout.LootListLimit
    local rareOrEpic = lootInfo.rarity == 3 or lootInfo.rarity == 4
    local equippable = lootInfo.itemType == 2 or lootInfo.itemType == 4 or lootInfo.itemType == 9

    return inInstance and inDungeonOrRaid and listNotAtMax and rareOrEpic and equippable
end

local function HandleLootEvent(...)
    local lootInfo = NanoLoot.Utilities.BuildLootInfo(...)
    if not lootInfo then
        return
    end

    if ShouldHandleLoot(lootInfo) then
        table.insert(NanoLootDB.LootList, lootInfo)
        GetItemInfo(lootInfo.originalLink)
        NanoLoot.UI.RenderLoot()
    end
end

local function InitializeAddon()
    InitializeDatabase()
    NanoLoot.UI.Initialize()
    NanoLoot.Config.CreateConfigFrame()
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("CHAT_MSG_LOOT")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_LOGOUT")

eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "nanoloot" then
            InitializeAddon()
            eventFrame:UnregisterEvent("ADDON_LOADED")
        end
    elseif event == "CHAT_MSG_LOOT" then
        HandleLootEvent(...)
    elseif event == "PLAYER_ENTERING_WORLD" then
        if _G["NANOLOOT_PANEL_BASE"] then
            Elements.Utilities.SetPixelScaling(_G["NANOLOOT_PANEL_BASE"])
        end
        eventFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "PLAYER_LOGOUT" then
        if NanoLootDB and NanoLootDB.LootList then
            NanoLootDB.LootList = {}
        end
    end
end)
