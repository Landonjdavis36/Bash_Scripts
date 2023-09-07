#!/bin/bash
osascript -e '
tell app "System Events"
    tell appearance preferences
        set dark mode to not dark mode
    end tell
end tell'
