local Constants = NanoLoot.Globals.Constants

local function GetTruncatedLink(link)
    if not link then
        return link
    end

    local maxLength = 20
    local itemName = link:match("%[(.+)%]")

    if itemName and string.len(itemName) > maxLength then
        local truncatedName = string.sub(itemName, 1, maxLength) .. "..."
        return link:gsub("%[(.+)%]", "[" .. truncatedName .. "]")
    end

    return link
end

local function CopyDefaults(target, defaults)
    for key, value in pairs(defaults) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = CopyDefaults({}, value)
            else
                target[key] = value
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            CopyDefaults(target[key], value)
        end
    end
    return target
end

local function NormalizePlayerName(player)
    if not player then
        return nil
    end
    return player:gsub("%-.+", "")
end

local function ExtractItemLink(message)
    if not message then
        return nil
    end
    return message:match("(|c.+|r)")
end

local function GetItemInfoData(itemLink, itemID)
    if not itemLink and not itemID then
        return nil
    end

    local info
    if C_Item and C_Item.GetItemInfo then
        info = { C_Item.GetItemInfo(itemLink or itemID) }
    else
        info = { GetItemInfo(itemLink or itemID) }
    end

    if not info[1] then
        return nil
    end

    return {
        link = info[2] or itemLink,
        rarity = info[3],
        itemLevel = info[4],
        classID = info[12],
        subClassID = info[13]
    }
end

local function IsEquippable(classID)
    return classID == 2 or classID == 4 or classID == 9
end

local function GetLootMessageText(lootInfo)
    if lootInfo.isSelf then
        return "Does anyone need this? " .. lootInfo.originalLink
    end

    return "Hey, do you need that item you just looted? (" ..
        lootInfo.originalLink .. ") If not, could I please grab it?"
end

local function SendLootChatMessage(lootInfo)
    if lootInfo.isSelf then
        local manualParty = IsInGroup(1)
        local instanceParty = IsInGroup(2)
        local manualRaid = IsInRaid(1)
        local instanceRaid = IsInRaid(2)
        local solo = not manualParty and not instanceParty and not manualRaid and not instanceRaid

        if manualRaid then
            SendChatMessage(GetLootMessageText(lootInfo), "RAID")
        end

        if instanceRaid then
            SendChatMessage(GetLootMessageText(lootInfo), "INSTANCE_CHAT")
        end

        if manualParty then
            SendChatMessage(GetLootMessageText(lootInfo), "PARTY")
        end

        if instanceParty then
            SendChatMessage(GetLootMessageText(lootInfo), "INSTANCE_CHAT")
        end

        if solo then
            SendChatMessage(GetLootMessageText(lootInfo), "SAY")
        end
    else
        SendChatMessage(GetLootMessageText(lootInfo), "WHISPER", nil, lootInfo.player)
    end
end

local function GetClassColoredName(playerName, guid)
    if not playerName or not guid then
        return playerName
    end

    local class = select(2, GetPlayerInfoByGUID(guid))
    if not class then
        return playerName
    end

    local classColor = C_ClassColor.GetClassColor(class)
    if not classColor then
        return playerName
    end

    return classColor:WrapTextInColorCode(playerName)
end

local function BuildLootRecord(eventMessage, playerName, guid, itemInfo)
    local link = itemInfo.link
    local playerNoRealm = NormalizePlayerName(playerName)
    local classPlayer = GetClassColoredName(playerName, guid)
    local classPlayerNoRealm = NormalizePlayerName(classPlayer)
    local currentPlayer = UnitName("player")

    return {
        classPlayer = classPlayer,
        itemLevel = itemInfo.itemLevel,
        link = NanoLoot.Utilities.GetTruncatedLink(link),
        originalLink = link,
        player = playerName,
        playerNoRealm = playerNoRealm,
        classPlayerNoRealm = classPlayerNoRealm,
        isSelf = playerNoRealm == currentPlayer,
        itemType = itemInfo.classID,
        itemSubType = itemInfo.subClassID
    }
end

local function ShouldTrackLoot(record)
    local inInstance, instanceType = IsInInstance()
    local inGroupInstance = instanceType == "party" or instanceType == "raid"
    local listNotAtMax = #NanoLootDB.LootList < Constants.LOOTLIST_LIMIT
    local rareOrEpic = record and (record.rarity == 3 or record.rarity == 4)
    local equippable = record and IsEquippable(record.classID)

    return inInstance and inGroupInstance and listNotAtMax and rareOrEpic and equippable
end

NanoLoot.Utilities = {
    CopyDefaults = CopyDefaults,
    GetTruncatedLink = GetTruncatedLink,
    NormalizePlayerName = NormalizePlayerName,
    ExtractItemLink = ExtractItemLink,
    GetItemInfoData = GetItemInfoData,
    BuildLootRecord = BuildLootRecord,
    ShouldTrackLoot = ShouldTrackLoot,
    SendLootChatMessage = SendLootChatMessage
}
