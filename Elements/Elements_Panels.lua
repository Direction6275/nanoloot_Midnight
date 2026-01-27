Elements.Panel.CreatePanel = function(
  parent,
  name,
  width,
  height,
  offsetX,
  offsetY,
  borderColour,
  backgroundColour,
  movable,
  point,
  relativePoint,
  opacity,
  invisible,
  onDragStop
)
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  borderColour = borderColour or Elements.Palette.RGB.BLACK
  backgroundColour = backgroundColour or Elements.Palette.RGB.ASH
  parent = parent or UIParent
  width = width or 300
  height = height or 150
  point = point or "TOPLEFT"
  relativePoint = relativePoint or "TOPLEFT"
  opacity = opacity or 0.85
  invisible = invisible or false

  if not name then name = Elements.Common.UUID() end

  local template = "BackdropTemplate"
  if invisible then
    template = nil
  end

  local panelBase = CreateFrame("Frame", name, parent, template)

  --panelBase:SetPoint(point, offsetX, offsetY)
  panelBase:SetPoint(point, parent, relativePoint, offsetX, offsetY)

  panelBase:SetSize(width, height)

  if not invisible then
    panelBase:SetBackdrop(
      {
        bgFile = Elements.Textures.PANEL_BG_TEXTURE,
        edgeFile = Elements.Textures.EDGE_TEXTURE,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
      }
    )
    panelBase:SetBackdropColor(
      backgroundColour[1],
      backgroundColour[2],
      backgroundColour[3],
      opacity
    )

    panelBase:SetBackdropBorderColor(unpack(borderColour))
  end

  panelBase:SetClampedToScreen(true)

  if movable then
    panelBase:EnableMouse(true)
    panelBase:SetMovable(true)
    panelBase:RegisterForDrag("LeftButton")
    panelBase:SetScript("OnDragStart", panelBase.StartMoving)

    if onDragStop then
      panelBase:SetScript("OnDragStop", onDragStop)
    else
      panelBase:SetScript("OnDragStop", panelBase.StopMovingOrSizing)
    end
  end

  return panelBase
end
