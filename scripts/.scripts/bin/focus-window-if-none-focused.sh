#!/bin/bash

# Get the ID of the currently focused window
current_window=$(yabai -m query --windows --window | jq '.id')

# If there's no current window (i.e., it was just closed), focus on another
# window on the current space
if [ -z "$current_window" ]; then
  yabai -m window --focus $(yabai -m query --windows --space | jq ".[0].id")
fi
