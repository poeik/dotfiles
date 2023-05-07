#!/usr/bin/env sh

desiredSpaceAmount=9
declare -A apps
apps["Microsoft Outlook"]=8
apps["Google Chrome"]=2
apps["iTerm2"]=1

start () {
  displayAmount=$(yabai -m query --displays | jq -c "length")
  spacesPerDisplay=$((desiredSpaceAmount / displayAmount))

  for i in {1..$displayAmount}
  do
    focusDisplay $i
    spacesOnDisplay=$(yabai -m query --displays --display | jq ".spaces | length")
    diff=$((spacesOnDisplay - spacesPerDisplay))

    if (( diff > 0 )); then
      echo "too many spaces, destroy! ${diff#-}"
      destroySpaces ${diff#-} # with absolute value
    elif (( diff < 0)); then
      echo "too few spaces create! $diff"
      createSpaces $diff
    fi
  done

  moveWindowsToCorrectSpaces
}

createSpaces() {
  amount=$1
  for i in {1..$amount}
  do
    yabai -m space --create
  done
}

destroySpaces() {
  amount=$1
  for i in {1..$amount}
  do
    yabai -m space --destroy
  done
}

focusDisplay() {
  displayId=$1
  yabai -m display --focus $displayId
}

moveWindowsToCorrectSpaces() {
  # Assoziatives Array mit Namen und Space
  for key space in ${(kv)apps}; do
    window_id=$(yabai -m query --windows | jq -c ".[] | select(.app | contains($key)) | .id")
    yabai -m window $window_id --space $space
  done
}

start
