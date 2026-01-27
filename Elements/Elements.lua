local addonLoaded = CreateFrame("Frame")

addonLoaded:RegisterEvent("ADDON_LOADED")
addonLoaded:RegisterEvent("PLAYER_LOGOUT")

addonLoaded:SetScript(
  "OnEvent",
  function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Elements" then
      -- Do addon loaded stuff here?
      addonLoaded:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGOUT" then
      -- --
    end
  end
)
