local Utils = {}

local function GetTruncatedLink(link)
    local maxLength = 20
    local itemName = link and link:match("%[(.+)%]")
    if not itemName then
        return link
    end

    if string.len(itemName) > maxLength then
        local truncatedName = string.sub(itemName, 1, maxLength) .. "..."
        return link:gsub("%[(.+)%]", "[" .. truncatedName .. "]")
    end

    return link
end

local function GetMessageText(lootInfo)
    if lootInfo.isSelf then
        return "Does anyone need this? " .. lootInfo.originalLink
    end

    return "Hey, do you need that item you just looted? (" .. lootInfo.originalLink .. ") If not, could I please grab it?"
end

local function SendLootChatMessage(lootInfo)
    if lootInfo.isSelf then
        local manualParty = IsInGroup(1)
        local instanceParty = IsInGroup(2)
        local manualRaid = IsInRaid(1)
        local instanceRaid = IsInRaid(2)
        local solo = not manualParty and not instanceParty and not manualRaid and not instanceRaid

        if manualRaid then
            SendChatMessage(GetMessageText(lootInfo), "RAID")
        end

        if instanceRaid then
            SendChatMessage(GetMessageText(lootInfo), "INSTANCE_CHAT")
        end

        if manualParty then
            SendChatMessage(GetMessageText(lootInfo), "PARTY")
        end

        if instanceParty then
            SendChatMessage(GetMessageText(lootInfo), "INSTANCE_CHAT")
        end

        if solo then
            SendChatMessage(GetMessageText(lootInfo), "SAY")
        end
    else
        SendChatMessage(GetMessageText(lootInfo), "WHISPER", nil, lootInfo.player)
    end
end

local function GetClassColorWrappedName(player, guid)
    local _, class = GetPlayerInfoByGUID(guid)
    local classColor = class and C_ClassColor.GetClassColor(class)
    if classColor and classColor.WrapTextInColorCode then
        return classColor:WrapTextInColorCode(player)
    end
    return player
end

local function GetItemDetails(itemLink)
    if not itemLink then
        return nil
    end

    local info = { GetItemInfo(itemLink) }
    if not info[1] then
        return nil
    end

    return {
        link = info[2],
        rarity = info[3],
        itemLevel = info[4],
        classID = info[12],
        subClassID = info[13]
    }
end

local function BuildLootInfo(...)
    local info = { ... }
    local message = info[1]
    local player = info[2]
    local guid = info[12]

    if not guid or not message then
        return nil
    end

    local link = message:match("(|c.+|r)")
    if not link then
        return nil
    end

    local itemDetails = GetItemDetails(link)
    if not itemDetails then
        return nil
    end

    local currentPlayer = UnitName("player")
    local playerNoRealm = player:gsub("%-.+", "")

    local classPlayer = GetClassColorWrappedName(player, guid)
    local classPlayerNoRealm = classPlayer:gsub("%-.+", "")
    local truncatedLink = GetTruncatedLink(itemDetails.link)

    return {
        classPlayer = classPlayer,
        classPlayerNoRealm = classPlayerNoRealm,
        itemLevel = itemDetails.itemLevel,
        itemType = itemDetails.classID,
        itemSubType = itemDetails.subClassID,
        link = truncatedLink,
        originalLink = itemDetails.link,
        player = player,
        playerNoRealm = playerNoRealm,
        isSelf = playerNoRealm == currentPlayer,
        rarity = itemDetails.rarity
    }
end

Utils.GetTruncatedLink = GetTruncatedLink
Utils.BuildLootInfo = BuildLootInfo
Utils.SendLootChatMessage = SendLootChatMessage

NanoLoot.Utilities = Utils
