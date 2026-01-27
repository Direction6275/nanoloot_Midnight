Elements.Buttons.CreateButton = function(
  frame,
  name,
  text,
  width,
  height,
  fontPath,
  textColour,
  textOffsetx,
  textOffsety,
  borderColour,
  backgroundColour,
  point,
  offsetx,
  offsety,
  textSize,
  textShadowColour,
  highlightColour
)
  width = width or 60
  height = height or 20
  point = point or "TOPLEFT"
  textColour = textColour or { 1, 1, 1 }
  textOffsetx = textOffsetx or 0
  textOffsety = textOffsety or 0
  borderColour = borderColour or { 1, 1, 1 }
  backgroundColour = backgroundColour or { 0, 0, 0 }
  offsetx = offsetx or 0
  offsety = offsety or 0
  textSize = textSize or 10
  textShadowColour = textShadowColour or { 0, 0, 0 }
  highlightColour = highlightColour or nil

  local button = CreateFrame("Button", name, frame, "BackdropTemplate")
  Elements.Utilities.SetPixelScaling(button)
  button:SetPoint(point, frame, offsetx, offsety)
  button:SetSize(width, height)
  button:SetBackdrop(
    {
      bgFile = Elements.Textures.PANEL_BG_TEXTURE,
      edgeFile = Elements.Textures.EDGE_TEXTURE,
      edgeSize = 1,
      insets = { left = 1, right = 1, top = 1, bottom = 1 }
    }
  )

  button:SetBackdropColor(unpack(backgroundColour))
  button:SetBackdropBorderColor(unpack(borderColour))

  Elements.Utilities.AddHighlightAndShadow(button, false, highlightColour)

  button:HookScript("OnEnter", function(self, motion)
    if not motion then return end
    -- pixelButton:SetBackdropBorderColor(unpack(Elements.Palette.RGB.WHITE))
    button:SetBackdropColor(unpack(Elements.Utilities.LightenColour(backgroundColour)))
  end)

  button:HookScript("OnLeave", function(self, motion)
    if not motion then return end
    -- pixelButton:SetBackdropBorderColor(unpack(borderColour))
    button:SetBackdropColor(unpack(backgroundColour))
  end)

  button:HookScript("OnClick", function(self, motion)
    if not motion then return end
    button:SetBackdropColor(unpack(backgroundColour))
  end)

  local buttonLabel = Elements.Text.CreateFreeText(fontPath, name .. "_TEXT", button, text, textSize, "NONE",
    textShadowColour, nil, textColour)
  buttonLabel:SetPoint("CENTER", button, textOffsetx, textOffsety)

  return button
end
