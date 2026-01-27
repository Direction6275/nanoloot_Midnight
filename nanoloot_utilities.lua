local function GetTruncatedLink(link)
    local truncatedLink = ''
    local maxLength = 20
    local itemName = link:match("%[(.+)%]")

    if string.len(itemName) > maxLength then
        local truncatedName = string.sub(itemName, 1, maxLength) .. "..."
        truncatedLink = link:gsub("%[(.+)%]", "[" .. truncatedName .. "]")

        return truncatedLink
    end

    return link
end

local function GetMessageText(lootInfo, isSelf)
    local messageText = ""

    if isSelf then
        messageText = "Does anyone need this? " .. lootInfo.originalLink
    else
        messageText = "Hey, do you need that item you just looted? (" ..
            lootInfo.originalLink .. ") If not, could I please grab it?"
    end

    return messageText
end

local function SendLootChatMessage(lootInfo)
    if lootInfo.isSelf then
        local manualParty = IsInGroup(1)
        local instanceParty = IsInGroup(2)
        local manualRaid = IsInRaid(1)
        local instanceRaid = IsInRaid(2)
        local solo = not manualParty and not instanceParty and not manualRaid and not instanceRaid

        if manualRaid then
            SendChatMessage(GetMessageText(lootInfo, true), "RAID")
        end

        if instanceRaid then
            SendChatMessage(GetMessageText(lootInfo, true), "INSTANCE_CHAT")
        end

        if manualParty then
            SendChatMessage(GetMessageText(lootInfo, true), "PARTY")
        end

        if instanceParty then
            SendChatMessage(GetMessageText(lootInfo, true), "INSTANCE_CHAT")
        end

        if solo then
            SendChatMessage(GetMessageText(lootInfo, true), "SAY")
        end
    else
        SendChatMessage(GetMessageText(lootInfo), "WHISPER", nil, lootInfo.player)
    end
end

local function LootInfo(...)
    local info        = { ... }
    local link        = info[1] and info[1]:match("(|c.+|r)") or nil
    local guid        = info[12]
    local player      = info[2]
    local class       = guid and select(2, GetPlayerInfoByGUID(guid)) or nil
    local classColor  = class and C_ClassColor.GetClassColor(class) or nil
    local classPlayer = player

    if classColor and player then
        classPlayer = classColor:WrapTextInColorCode(player)
    end

    local itemName, _, itemQuality, itemLevel, _, _, _, _, _, _, _, classID, subclassID = nil, nil, nil, nil, nil, nil,
        nil, nil, nil, nil, nil, nil, nil

    if link then
        itemName, _, itemQuality, itemLevel, _, _, _, _, _, _, _, classID, subclassID = GetItemInfo(link)
    end

    local rarity      = itemQuality or 0
    itemLevel         = itemLevel or 0
    local itemID      = info[1] and info[1]:match("item:(%d*):") or nil
    local itemType    = classID or 0
    local itemSubType = subclassID or 0

    return player, classPlayer, link, rarity, itemLevel, itemID, itemType, itemSubType
end

NanoLoot.Utilities = {
    GetTruncatedLink = GetTruncatedLink,
    LootInfo = LootInfo,
    SendLootChatMessage = SendLootChatMessage
}
