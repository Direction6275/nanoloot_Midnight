Elements.Utilities.LightenColour = function(colour, percent)
  percent = percent or 0.15

  local lighter = {}

  for _, value in ipairs(colour) do
    local lightened = (percent * 1) + value

    if lightened > 1 then
      lightened = 1
    end

    table.insert(lighter, lightened)
  end

  return lighter
end

Elements.Utilities.SetPixelScaling = function(frame)
  frame:SetIgnoreParentScale(true)
  frame:SetScale(768 / (select(2, GetPhysicalScreenSize())))
end

Elements.Utilities.AddShadow = function(parent, shadowPoint, shadowOffsetY)
  shadowPoint = shadowPoint or "BOTTOMLEFT"
  shadowOffsetY = shadowOffsetY or 1

  local shadow =
  CreateFrame("Frame", parent:GetName() .. "_SHADOW_BORDER", parent, "BackdropTemplate")
  Elements.Utilities.SetPixelScaling(shadow)

  shadow:SetPoint(shadowPoint, parent, 1, shadowOffsetY)
  shadow:SetSize((parent:GetWidth() - 2), 1)
  shadow:SetBackdrop({ bgFile = Elements.Textures.PANEL_BG_TEXTURE })
  shadow:SetBackdropColor(0, 0, 0, 0.40)
end


Elements.Utilities.AddHighlightAndShadow = function(parent, invert, highlightColour)
  highlightColour = highlightColour or { 1, 1, 1, 0.40 }

  local highlightPoint = "TOPLEFT"
  local highlightOffsetY = -1

  local shadowPoint = "BOTTOMLEFT"
  local shadowOffsetY = 1

  if invert then
    shadowPoint = "TOPLEFT"
    shadowOffsetY = -1

    highlightPoint = "BOTTOMLEFT"
    highlightOffsetY = 1
  end

  -- Highlight
  local highlight = CreateFrame("Frame", parent:GetName() .. "_INNER_BORDER", parent, "BackdropTemplate")
  Elements.Utilities.SetPixelScaling(highlight)

  highlight:SetPoint(highlightPoint, parent, 1, highlightOffsetY)
  highlight:SetSize((parent:GetWidth() - 2), 1)
  highlight:SetBackdrop({ bgFile = Elements.Textures.PANEL_BG_TEXTURE })
  highlight:SetBackdropColor(unpack(highlightColour))

  -- Shadow
  Elements.Utilities.AddShadow(parent, shadowPoint, shadowOffsetY)

  -- -- Inner Border
  -- innerBorder:SetPoint("TOPLEFT", parent, 1, -1)
  -- innerBorder:SetSize((parent:GetWidth() - 2), (parent:GetHeight() - 2))
  -- innerBorder:SetBackdrop(
  --   {
  --     edgeFile = Reported2.EDGE_TEXTURE,
  --     edgeSize = 1
  --   }
  -- )
  -- innerBorder:SetBackdropBorderColor(1, 1, 1, 0.1)
end
