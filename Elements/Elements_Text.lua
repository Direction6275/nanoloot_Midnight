Elements.Text.CreateFreeText = function(fontPath, name, parent, text, size, flags, shadowColor, shadowOpacity, textColor)
  size = size or 12
  flags = flags or "OUTLINE"
  shadowColor = shadowColor or Elements.Palette.RGB.BLACK
  shadowOpacity = shadowOpacity or 0.85
  textColor = textColor or { 1, 1, 1 }

  local textElement = parent:CreateFontString(name, "ARTWORK")

  --textElement:SetIgnoreParentScale(false)
  textElement:SetFont(fontPath, size, flags)
  textElement:SetTextColor(textColor[1], textColor[2], textColor[3])
  textElement:SetShadowColor(shadowColor[1], shadowColor[2], shadowColor[3], shadowOpacity)
  textElement:SetShadowOffset(1, -1)
  textElement:SetText(text)

  return textElement
end

Elements.Text.CreateText = function(
  fontPath,
  name,
  frame,
  anchorPoint,
  relativePoint,
  textFrameHeight,
  text,
  size,
  offsetX,
  offsetY,
  point,
  flags,
  shadowColor,
  shadowOpacity
)
  point = point or "TOPLEFT"
  relativePoint = relativePoint or "TOPLEFT"
  size = size or 12
  offsetX = offsetX or Elements.Units.Padding
  offsetY = offsetY or 0
  flags = flags or "OUTLINE"
  shadowColor = shadowColor or Elements.Palette.RGB.BLACK
  shadowOpacity = shadowOpacity or 0.85

  local textFrame = Elements.Common.CreateFrameBlock(frame, name .. "_FRAMEBLOCK")
  textFrame:SetPoint("TOPLEFT", anchorPoint, relativePoint, 0, offsetY)

  local textElement = Elements.Text.CreateFreeText(fontPath, name, textFrame, text, size, flags, shadowColor,
    shadowOpacity)

  if not textFrameHeight and textElement:GetStringHeight() > 0 then
    textFrameHeight = textElement:GetStringHeight()
  else
    textFrameHeight = textFrameHeight or size + 17
  end

  textFrame:SetSize(frame:GetWidth(), textFrameHeight)
  textElement:SetPoint(point, textFrame, offsetX, 0)

  return textFrame, textElement
end

Elements.Text.CreateSeparator = function(name, panel, parent, relativePoint, blockHeight)
  relativePoint = relativePoint or "TOPLEFT"
  blockHeight = blockHeight or Elements.Units.Padding

  local frameBlock = Elements.Common.CreateFrameBlock(panel)
  frameBlock:SetPoint("TOPLEFT", parent, relativePoint)
  frameBlock:SetSize(panel:GetWidth(), blockHeight)

  local separator = CreateFrame("Frame", name, frameBlock, "BackdropTemplate")

  separator:SetPoint("CENTER", frameBlock, "BOTTOM")
  separator:SetSize((panel:GetWidth() - (Elements.Units.Padding * 2)), 1)
  separator:SetBackdrop({ bgFile = Elements.Textures.PANEL_BG_TEXTURE })
  separator:SetBackdropColor(
    Elements.Palette.RGB.BLACK[1],
    Elements.Palette.RGB.BLACK[2],
    Elements.Palette.RGB.BLACK[3]
  )

  return frameBlock
end

Elements.Text.RainbowText = function(text, palette)
  palette = palette or {
    "9B5DE5",
    "F15BB5",
    "FEE440",
    "00BBF9",
    "00F5D4"
  }
  local rainbowText = ""
  local paletteIndex = 1

  for char in text:gmatch(".") do
    if paletteIndex > #palette then
      paletteIndex = 1
    end
    print(char)
    rainbowText = rainbowText .. "|cff" .. palette[paletteIndex] .. char .. "|r"

    paletteIndex = paletteIndex + 1
  end

  return rainbowText
end
