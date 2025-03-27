--------------------------------------------------------
-- Bind Alt-TAB to type a specific string
--------------------------------------------------------
hs.hotkey.bind({"alt"}, "tab", function()
    hs.eventtap.keyStrokes("Suur Parim")
end)

--------------------------------------------------------
-- Type my email address
--------------------------------------------------------
hs.hotkey.bind({"alt"}, "q", function()
    hs.eventtap.keyStrokes("Lugupidamisega,\rIgnar Valme")
end)

--------------------------------------------------------
-- Reload Hammerspoon automatically when the config is saved
--------------------------------------------------------
hs.hotkey.bind({"cmd", "ctrl"}, "r", function()
    hs.reload()
    hs.alert.show("Hammerspoon Config Reloaded")
end)

--------------------------------------------------------
-- Move windows to the left half of the screen
--------------------------------------------------------
hs.hotkey.bind({"ctrl", "alt"}, "left", function()
    hs.window.focusedWindow():moveToUnit(hs.layout.left50)
end)

--------------------------------------------------------
-- Move windows to the right half of the screen
--------------------------------------------------------
hs.hotkey.bind({"ctrl", "alt"}, "right", function()
    hs.window.focusedWindow():moveToUnit(hs.layout.right50)
end)

--------------------------------------------------------
-- Move windows to the center of the screen
--------------------------------------------------------
hs.hotkey.bind({"ctrl", "alt"}, "down", function()
    hs.window.focusedWindow():centerOnScreen()
end)

--------------------------------------------------------
-- Reload Hammerspoon configuration when files change
--------------------------------------------------------
function reloadConfig(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
