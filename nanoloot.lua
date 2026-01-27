local Constants = NanoLoot.Globals.Constants
local Defaults = NanoLoot.Globals.Defaults

local pendingLoot = {}

local function EnsureDatabase()
    NanoLootDB = NanoLoot.Utilities.CopyDefaults(NanoLootDB or {}, Defaults)

    if type(NanoLootDB.LootList) ~= "table" then
        NanoLootDB.LootList = {}
    end
end

local function QueuePendingLoot(itemID, message, playerName, guid)
    if not itemID then
        return
    end
    pendingLoot[itemID] = {
        message = message,
        playerName = playerName,
        guid = guid
    }
    if C_Item and C_Item.RequestLoadItemDataByID then
        C_Item.RequestLoadItemDataByID(tonumber(itemID))
    end
end

local function HandleLootMessage(message, playerName, guid)
    if not guid or not message then
        return
    end

    local itemLink = NanoLoot.Utilities.ExtractItemLink(message)
    if not itemLink then
        return
    end

    local itemID = message:match("item:(%d+):")
    local itemInfo = NanoLoot.Utilities.GetItemInfoData(itemLink, itemID)
    if not itemInfo then
        QueuePendingLoot(itemID, message, playerName, guid)
        return
    end

    if not NanoLoot.Utilities.ShouldTrackLoot(itemInfo) then
        return
    end

    local lootRecord = NanoLoot.Utilities.BuildLootRecord(message, playerName, guid, itemInfo)
    table.insert(NanoLootDB.LootList, lootRecord)
    NanoLoot.UI.RenderLoot()
end

local function HandleItemDataLoadResult(itemID, success)
    if not success then
        return
    end

    local entry = pendingLoot[tostring(itemID)] or pendingLoot[itemID]
    if not entry then
        return
    end

    pendingLoot[tostring(itemID)] = nil
    pendingLoot[itemID] = nil

    HandleLootMessage(entry.message, entry.playerName, entry.guid)
end

local function NanoLootEventHandler(_, event, ...)
    if event == "CHAT_MSG_LOOT" then
        local message, playerName, _, _, _, _, _, _, _, _, _, guid = ...
        HandleLootMessage(message, playerName, guid)
    elseif event == "ITEM_DATA_LOAD_RESULT" then
        local itemID, success = ...
        HandleItemDataLoadResult(itemID, success)
    end
end

local function InitialiseNanoLoot()
    local listener = CreateFrame("Frame")
    listener:RegisterEvent("CHAT_MSG_LOOT")
    listener:RegisterEvent("ITEM_DATA_LOAD_RESULT")
    listener:SetScript("OnEvent", NanoLootEventHandler)

    local panel = NanoLoot.UI.CreateMainPanel()
    local titleBar = NanoLoot.UI.CreateTitleBar(panel)
    NanoLoot.UI.CreateWaitingBar(titleBar)

    NanoLoot.UI.SetMainPanelSize()
    NanoLoot.UI.RenderLoot()
end

local function HandlePlayerEnteringWorld()
    if _G["NANOLOOT_PANEL_BASE"] then
        Elements.Utilities.SetPixelScaling(_G["NANOLOOT_PANEL_BASE"])
    end
end

local loadingEvents = CreateFrame("Frame")
loadingEvents:RegisterEvent("ADDON_LOADED")
loadingEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
loadingEvents:RegisterEvent("PLAYER_LOGOUT")

loadingEvents:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "nanoloot" then
        EnsureDatabase()
        InitialiseNanoLoot()
        NanoLoot.Config.CreateConfigFrame()
        loadingEvents:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_ENTERING_WORLD" then
        HandlePlayerEnteringWorld()
        loadingEvents:UnregisterEvent("PLAYER_ENTERING_WORLD")
    elseif event == "PLAYER_LOGOUT" then
        if NanoLootDB and NanoLootDB.LootList then
            NanoLootDB.LootList = {}
        end
    end
end)
