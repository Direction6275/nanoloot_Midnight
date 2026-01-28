local function NanoLootEventHandler(_, event, ...)
    if event == "CHAT_MSG_LOOT" then
        local info = { ... }
        local guid = info[12]
        if not guid then
            return
        end

        local currentPlayer = UnitName("player")
        local player, classPlayer, link, rarity, itemLevel, itemID, itemType, itemSubType = NanoLoot.Utilities.LootInfo(...)
        local truncatedLink = NanoLoot.Utilities.GetTruncatedLink(link)
        local playerNoRealm = player:gsub("%-.+", "")
        local classPlayerNoRealm = classPlayer:gsub("%-.+", "")
        local isSelf = playerNoRealm == currentPlayer
        local inInstance, instanceType = IsInInstance()
        local inDungeonOrRaid = instanceType == 'party' or instanceType == 'raid'
        local listNotAtMax = #NanoLootDB.LootList ~= NanoLoot.Globals.NANOLOOT_LOOTLIST_LIMIT
        local rareOrEpic = rarity == 3 or rarity == 4
        -- itemType: 2=Armor, 4=Weapon, 9=Container (bag slots)
        -- If itemType is nil (async loading), allow rare/epic items through since they're likely equippable in dungeon/raid
        local equippable = itemType == nil or itemType == 2 or itemType == 4 or itemType == 9
        local shouldHandle = inInstance and inDungeonOrRaid and listNotAtMax and rareOrEpic and equippable

        -- Debug:
        -- shouldHandle = true

        if shouldHandle then
            local loot = {
                classPlayer = classPlayer,
                itemLevel = itemLevel,
                link = truncatedLink,
                originalLink = link,
                player = player,
                playerNoRealm = playerNoRealm,
                classPlayerNoRealm = classPlayerNoRealm,
                isSelf = isSelf,
                itemType = itemType,
                itemSubType = itemSubType
            }
            table.insert(NanoLootDB.LootList, loot)
            C_Item.GetItemInfo(link)
            NanoLoot.UI.RenderLoot()
        end
    end
end

local function InitialiseNanoLoot()
    local NanoLootListener = CreateFrame("Frame")
    NanoLootListener:RegisterEvent("CHAT_MSG_LOOT")
    NanoLootListener:SetScript("OnEvent", NanoLootEventHandler)

    local NanoLootPanel = NanoLoot.UI.CreateMainPanel()
    local NanoLootTitleBar = NanoLoot.UI.CreateTitleBar(NanoLootPanel)
    NanoLoot.UI.CreateWaitingBar(NanoLootTitleBar)

    NanoLoot.UI.SetMainPanelSize()

    NanoLoot.UI.RenderLoot()
end

local loadingEvents = CreateFrame("Frame")
loadingEvents:RegisterEvent("ADDON_LOADED")
loadingEvents:RegisterEvent("PLAYER_ENTERING_WORLD")
loadingEvents:RegisterEvent("PLAYER_LOGOUT")

loadingEvents:SetScript(
    "OnEvent",
    function(_, event, arg1)
        if event == "ADDON_LOADED" and arg1 == "nanoloot_Midnight" then
            if not NanoLootDB then
                NanoLootDB = {}
                NanoLootDB.LootList = {}
                NanoLootDB.TitleBarBackground = Elements.Palette.RGB.PURPLE
                NanoLootDB.UseClassColour = false
                NanoLootDB.HideWhenEmpty = false
                NanoLootDB.UseCustomFont = false
                NanoLootDB.CustomFontName = nil
                NanoLootDB.CustomFontPath = nil
                NanoLootDB.FontSize = 12
                NanoLootDB.PanelPoint = "TOPLEFT"
                NanoLootDB.PanelRelativePoint = "TOPLEFT"
                NanoLootDB.PanelPositionX = 10
                NanoLootDB.PanelPositionY = -10
            else
                if not NanoLootDB.LootList then
                    NanoLootDB.LootList = {}
                end

                if not NanoLootDB.TitleBarBackground then
                    NanoLootDB.TitleBarBackground = Elements.Palette.RGB.PURPLE
                end

                if not NanoLootDB.UseClassColour then
                    NanoLootDB.UseClassColour = false
                end

                if not NanoLootDB.UseCustomFont then
                    NanoLootDB.UseCustomFont = false
                end

                if not NanoLootDB.CustomFontName then
                    NanoLootDB.CustomFontName = nil
                end

                if not NanoLootDB.CustomFontPath then
                    NanoLootDB.CustomFontPath = nil
                end

                if not NanoLootDB.FontSize then
                    NanoLootDB.FontSize = 12
                end

                if not NanoLootDB.HideWhenEmpty then
                    NanoLootDB.HideWhenEmpty = false
                end

                if not NanoLootDB.PanelPoint then
                    NanoLootDB.PanelPoint = "TOPLEFT"
                end

                if not NanoLootDB.PanelRelativePoint then
                    NanoLootDB.PanelRelativePoint = "TOPLEFT"
                end

                if not NanoLootDB.PanelPositionX then
                    NanoLootDB.PanelPositionX = 10
                end

                if not NanoLootDB.PanelPositionY then
                    NanoLootDB.PanelPositionY = -10
                end
            end

            InitialiseNanoLoot()
            NanoLoot.Config.CreateConfigFrame()

            loadingEvents:UnregisterEvent("ADDON_LOADED")
        end

        if event == "PLAYER_ENTERING_WORLD" then
            if _G["NANOLOOT_PANEL_BASE"] then
                Elements.Utilities.SetPixelScaling(_G["NANOLOOT_PANEL_BASE"])
            end
            loadingEvents:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end

        if event == "PLAYER_LOGOUT" then
            if NanoLootDB and NanoLootDB.LootList then
                NanoLootDB.LootList = {}
            end
        end
    end
)
