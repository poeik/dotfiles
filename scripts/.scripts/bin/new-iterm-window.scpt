tell application "System Events"
    -- if finder is the active app, open iTerm in the current folder, else open iTerm in home dir
    set activeApp to name of first application process whose frontmost is true
    if "Finder" is in activeApp then
      tell application "System Events"
          -- Runs the service "New iTerm2 Window Here"
          keystroke "b" using {command down, option down, control down}
      end tell
    else
      tell application "iTerm"
          create window with default profile
          activate
      end tell
    end if
end tell
