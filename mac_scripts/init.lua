--------------------------------------------------------
-- Bind Ctrl(win key)-Q to type a specific string
--------------------------------------------------------
hs.hotkey.bind({"ctrl"}, "tab", function()
    hs.eventtap.keyStrokes("mute")
end)

--------------------------------------------------------
-- Type my email address
--------------------------------------------------------
hs.hotkey.bind({"alt"}, "e", function()
    hs.eventtap.keyStrokes("Lugupidamisega,\rIgnar Valme")
end)

--------------------------------------------------------
-- Bind Alt-W for Isikukood
--------------------------------------------------------
hs.hotkey.bind({"alt"}, "W", function()
    hs.eventtap.keyStrokes("39002190224")
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
-- use Delete key and send Cmd+Backspace in Finder
--------------------------------------------------------
deleteTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local keyCode = event:getKeyCode()
    local isDelete = keyCode == hs.keycodes.map["forwarddelete"]

    if isDelete and hs.application.frontmostApplication():name() == "Finder" then
        hs.eventtap.keyStroke({"cmd"}, "delete", 0)
        return true -- suppress the original Delete key
    end
end)

deleteTap:start()

--------------------------------------------------------
-- Home key = beginning of line everywhere
--------------------------------------------------------
hs.hotkey.bind({}, "home", function()
    hs.eventtap.keyStroke({"cmd"}, "left") -- start of line
end)

--------------------------------------------------------
-- Bind Ctrl+Alt+X to perform Cmd+X (Cut)
--------------------------------------------------------
hs.hotkey.bind({"ctrl", "alt"}, "x", function()
    hs.eventtap.keyStroke({"cmd"}, "x")
end)


--------------------------------------------------------
-- Prevent rename in Finder when pressing Enter
-- and open the file instead (Cmd + Down)
--------------------------------------------------------

local enterWatcher = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local keyCode = event:getKeyCode()
    local isEnter = keyCode == hs.keycodes.map["return"]
    local app = hs.application.frontmostApplication()

    if isEnter and app:name() == "Finder" then
        -- Delay a bit and then trigger Cmd + Down
        hs.timer.doAfter(0.05, function()
            hs.eventtap.keyStroke({"cmd"}, "down", 0)
        end)
        return true -- Suppress original Enter key (stops rename)
    end

    return false
end)

enterWatcher:start()

--------------------------------------------------------
-- Map End key to Cmd + Right Arrow
--------------------------------------------------------
endKeyTap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(event)
    local keyCode = event:getKeyCode()
    local isEndKey = keyCode == hs.keycodes.map["end"]

    if isEndKey and hs.application.frontmostApplication():name() == "Finder" then
        hs.eventtap.keyStroke({"cmd"}, "right", 0)
        return true  -- suppress original End behavior
    end
end)

endKeyTap:start()


--------------------------------------------------------
-- Reload Hammerspoon configuration when files change
--------------------------------------------------------
function reloadConfig(files)
    hs.reload()
end
hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()

--------------------------------------------------------
-- Remap cmd + L to lock screen (globally) for WIN use ctrl
--------------------------------------------------------
hs.hotkey.bind({"cmd"}, "L", function()
    hs.caffeinate.lockScreen()
end)
