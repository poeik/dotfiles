#!/usr/bin/env sh

desiredSpaceAmount=9

declare -A apps
# Code
apps["iTerm2"]=1
apps["IntelliJ IDEA"]=1
apps["CLion"]=1

# utilities
apps["Google Chrome"]=2
apps["Notion"]=4

# messaging
apps["Microsoft Outlook"]=8
apps["Microsoft Teams"]=7

start () {
  displayAmount=$(yabai -m query --displays | jq -c "length")
  spacesPerDisplay=$((desiredSpaceAmount / displayAmount))

  for i in {1..$displayAmount}
  do
    focusDisplay $i
    spacesOnDisplay=$(yabai -m query --displays --display | jq ".spaces | length")
    diff=$((spacesOnDisplay - spacesPerDisplay))

    if (( diff > 0 )); then
      echo "too many spaces, destroy! $diff"
      destroySpaces $diff # with absolute value
    elif (( diff < 0)); then
      echo "too few spaces create! ${diff#-}"
      createSpaces ${diff#-}
    fi
  done

  moveWindowsToCorrectSpaces
  yabai -m space --focus 1
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
    yabai -m space --destroy last
  done
}

focusDisplay() {
  displayId=$1
  yabai -m display --focus $displayId
}

moveWindowsToCorrectSpaces() {
  # Assoziatives Array mit Namen und Space
  for key space in ${(kv)apps}; do
    idsAsString=$(yabai -m query --windows | jq -c ".[] | select(.app | contains($key)) | .id")
    idsAsString="${idsAsString//[^0-9]/\n}" 
    window_ids=("${(@s/\n/)idsAsString}") #" # this hash is only because of lsp problems

    # echo "$key $window_ids"
    for window_id in "${window_ids[@]}" 
    do
      # move window to space
      yabai -m window $window_id --space $space
    done
  done
}

start
