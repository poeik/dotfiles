-- Opens a new Ghostty window in the folder of the frontmost Finder window.
-- If Finder is not the frontmost application, opens a plain Ghostty window instead.

tell application "System Events"
	set frontApp to name of first application process whose frontmost is true
end tell

if frontApp is "Finder" then
	tell application "Finder"
		if (count of windows) > 0 then
			set targetFolder to (POSIX path of (target of front window as alias))
		else
			-- No Finder window open, fall back to the Desktop
			set targetFolder to (POSIX path of (path to desktop))
		end if
	end tell
	
	tell application "Ghostty"
		set cfg to new surface configuration
		set initial working directory of cfg to targetFolder
		set win to new window with configuration cfg
	end tell
else
	tell application "Ghostty"
		set win to new window
	end tell
end if
