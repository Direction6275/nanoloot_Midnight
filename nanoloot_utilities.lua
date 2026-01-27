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
    local link        = info[1]:match("(|c.+|r)")
    local guid        = info[12]
    local player      = info[2]
    local class       = select(2, GetPlayerInfoByGUID(guid))
    local classColor  = C_ClassColor.GetClassColor(class)
    local classPlayer = classColor:WrapTextInColorCode(player)
    local rarity      = select(3, GetItemInfo(link))
    local itemLevel   = select(4, GetItemInfo(link))
    local itemID      = info[1]:match("item:(%d*):")
    local itemType    = select(12, GetItemInfo(link))
    local itemSubType = select(13, GetItemInfo(link))

    return player, classPlayer, link, rarity, itemLevel, itemID, itemType, itemSubType
end

NanoLoot.Utilities = {
    GetTruncatedLink = GetTruncatedLink,
    LootInfo = LootInfo,
    SendLootChatMessage = SendLootChatMessage
}
