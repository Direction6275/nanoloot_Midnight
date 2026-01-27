Elements = {}

Elements.Common = {}
Elements.Panel = {}
Elements.Palette = {}
Elements.Textures = {}
Elements.Text = {}
Elements.Buttons = {}
Elements.Checkboxes = {}
Elements.Units = {}
Elements.Utilities = {}

-- Palette
Elements.Palette.START = "|cff"
Elements.Palette.RESET = "|r"

Elements.Palette.RGB = {
  ["ASH"] = { 0.066, 0.066, 0.066 },
  ["BLACK"] = { 0, 0, 0 },
  ["BLUE"] = { 0.26, 0.43, 1.00 },
  ["BRIGHT_YELLOW"] = { 1.00, 0.96, 0.41 },
  ["DARK_GREY"] = { 0.20, 0.20, 0.24 },
  ["GREY"] = { 0.30, 0.31, 0.37 },
  ["LIGHT_GREY"] = { 0.54, 0.55, 0.66 },
  ["PALE_BLUE"] = { 0.72, 0.78, 0.98 },
  ["PINK"] = { 1, 0.4, 0.73 },
  ["PURPLE"] = { 0.58, 0.38, 1 },
  ["RED"] = { 0.98, 0.08, 0.35 },
  ["RICH_YELLOW"] = { 1, 0.72, 0.24 },
  ["TEAL"] = { 0, 1, 0.59 },
  ["WHITE"] = { 1, 1, 1 }
}

Elements.Palette.Hex = {
  -- ↓ #000000 ↓ --
  ["BLACK"] = Elements.Palette.START .. "000000",
  -- ↓ #6B8BF5 ↓ --
  ["BLUE"] = Elements.Palette.START .. "6B8BF5",
  -- ↓ #FFF569 ↓ --
  ["BRIGHT_YELLOW"] = Elements.Palette.START .. "FFF569",
  -- ↓ #32333e ↓ --
  ["DARK_GREY"] = Elements.Palette.START .. "32333e",
  -- ↓ #4D4E5F ↓ --
  ["GREY"] = Elements.Palette.START .. "4D4E5F",
  -- ↓ #8A8CA8 ↓ --
  ["LIGHT_GREY"] = Elements.Palette.START .. "8A8CA8",
  -- ↓ #B8C8F9 ↓ --
  ["PALE_BLUE"] = Elements.Palette.START .. "B8C8F9",
  -- ↓ #FF66BA ↓ --
  ["PINK"] = Elements.Palette.START .. "FF66BA",
  -- ↓ #9560FF ↓ --
  ["PURPLE"] = Elements.Palette.START .. "9560FF",
  -- ↓ #FA1459 ↓ --
  ["RED"] = Elements.Palette.START .. "FA1459",
  -- ↓ #FFB83C ↓ --
  ["RICH_YELLOW"] = Elements.Palette.START .. "FFB83C",
  -- ↓ #00FF96 ↓ --
  ["TEAL"] = Elements.Palette.START .. "00FF96",
  -- ↓ #ffffff ↓ --
  ["WHITE"] = Elements.Palette.START .. "ffffff"
}

Elements.Palette.RGB.CLEAR_BUTTON_BG = { 255 / 255, 30 / 255, 90 / 255 }
Elements.Palette.RGB.CLEAR_BUTTON_BORDER = { 81 / 255, 0 / 255, 21 / 255 }

-- Texutres
Elements.Textures.BUTTON_BG_TEXTURE = [[Interface\Buttons\WHITE8X8]]
Elements.Textures.PANEL_BG_TEXTURE = [[Interface\Buttons\WHITE8X8]]
Elements.Textures.EDGE_TEXTURE = [[Interface\Buttons\WHITE8X8]]

-- Units
Elements.Units.Padding = 10
Elements.Units.TextFrameHeight = 30
Elements.Units.CheckboxWidth = 16
Elements.Units.CheckboxHeight = 16


-- Common
local random = math.random
Elements.Common.UUID = function()
  local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
  return string.gsub(template, '[xy]', function(c)
    local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
    return string.format('%x', v)
  end)
end

Elements.Common.CreateFrameBlock = function(parent, name)
  name = name or ("ELEMENTS_FRAMEBLOCK_" .. Elements.Common.UUID())

  local frameBlock = CreateFrame(
    "Frame",
    name,
    parent,
    "BackdropTemplate"
  )

  -- frameBlock:SetBackdrop({ bgFile = Elements.Textures.PANEL_BG_TEXTURE })
  -- local keyset = {}
  -- for k in pairs(Elements.Palette.RGB) do
  --   table.insert(keyset, k)
  -- end
  -- local dye = Elements.Palette.RGB[keyset[math.random(#keyset)]]
  -- frameBlock:SetBackdropColor(unpack(dye))

  return frameBlock
end
