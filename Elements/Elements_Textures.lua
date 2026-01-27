local function AnimateTexCoords(
  texture,
  textureWidth,
  textureHeight,
  frameWidth,
  frameHeight,
  numFrames,
  elapsed,
  throttle
)
  if (not texture.frame) then
    texture.frame = 1
    texture.throttle = throttle
    texture.columnWidth = frameWidth / textureWidth
    texture.rowHeight = frameHeight / textureHeight
  end
  local frame = texture.frame
  if (not texture.throttle or texture.throttle > throttle) then
    local framesToAdvance = floor(texture.throttle / throttle)
    while (frame + framesToAdvance > numFrames) do
      frame = frame - numFrames
    end
    frame = frame + framesToAdvance
    texture.throttle = 0
    local left = mod(frame - 1, numFrames) * texture.columnWidth
    local right = left + texture.columnWidth
    local bottom = ceil(frame / numFrames) * texture.rowHeight
    local top = bottom - texture.rowHeight
    texture:SetTexCoord(left, right, top, bottom)

    texture.frame = frame
  else
    texture.throttle = texture.throttle + elapsed
  end
end

Elements.Textures.SpawnAnimatedTexture = function(
  name,
  parent,
  texturePath,
  textureWidth,
  textureHeight,
  frameWidth,
  frameHeight,
  numFrames,
  throttle
)
  throttle = throttle or 0.05

  local frame = CreateFrame("Frame", "ELEMENTS_ANIMATED_TEXTUREFRAME_" .. strupper(name), parent)
  local texture = frame:CreateTexture("ELEMENTS_ANIMATED_TEXTURE_" .. strupper(name), "BACKGROUND")

  -- Not needed?
  -- local factor = PixelUtil.GetPixelToUIUnitFactor()

  Elements.Utilities.SetPixelScaling(frame)

  frame:SetPoint("CENTER")
  --PixelUtil.SetSize(frame, frameWidth, frameHeight)
  frame:SetSize(frameWidth, frameHeight)

  texture:SetTexture(texturePath, "CLAMP", nil, "NEAREST")
  texture:SetAllPoints(frame)

  frame.texture = texture

  frame:SetScript("OnUpdate",
    function(self, elapsed)
      AnimateTexCoords(
        self.texture,
        textureWidth,
        textureHeight,
        frameWidth,
        frameHeight,
        numFrames,
        elapsed,
        throttle
      )
    end)

  return frame, texture
end
