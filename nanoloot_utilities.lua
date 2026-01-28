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
    local itemID      = info[1]:match("item:(%d*):")

    -- Use C_Item.GetItemInfo (namespaced in 10.2.6+) with single call for efficiency
    local itemName, _, rarity, itemLevel, _, _, _, _, _, _, _, itemType, itemSubType = C_Item.GetItemInfo(link)

    -- Handle async item data - if nil, extract rarity from link color code
    -- Link format: |cffRRGGBB|Hitem:...|h[Name]|h|r
    -- Rarity colors: Poor=9d9d9d, Common=ffffff, Uncommon=1eff00, Rare=0070dd, Epic=a335ee
    if not rarity then
        local colorCode = info[1]:match("|cff(%x%x%x%x%x%x)")
        if colorCode then
            local rarityMap = {
                ["9d9d9d"] = 0, -- Poor
                ["ffffff"] = 1, -- Common
                ["1eff00"] = 2, -- Uncommon
                ["0070dd"] = 3, -- Rare
                ["a335ee"] = 4, -- Epic
                ["ff8000"] = 5, -- Legendary
                ["e6cc80"] = 6, -- Artifact
                ["00ccff"] = 7, -- Heirloom
            }
            rarity = rarityMap[colorCode:lower()] or 1
        end
    end

    return player, classPlayer, link, rarity, itemLevel, itemID, itemType, itemSubType
end

NanoLoot.Utilities = {
    GetTruncatedLink = GetTruncatedLink,
    LootInfo = LootInfo,
    SendLootChatMessage = SendLootChatMessage
}
