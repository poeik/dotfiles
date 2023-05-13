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
apps["Finder"]=3
apps["Preview"]=3

# messaging
apps["Microsoft Outlook"]=8
apps["Microsoft Teams"]=7

start () {
  local displayAmount=$(yabai -m query --displays | jq -c "length")
  if [[ ! ($displayAmount -eq 3 || $displayAmount -eq 1) ]]; then 
    echo "Behaviour for $displayAmount is not defined, exit"
    return 0
  fi
  echo "Currently are $displayAmount display attached."

  local spacesPerDisplay=$((desiredSpaceAmount / displayAmount))

  for i in {1..$displayAmount}
  do
    local displayId=$i
    focusDisplay $displayId
    local currentSpaceAmountOfActiveDisplay=$(yabai -m query --displays --display | jq ".spaces | length")
    local diff=$((currentSpaceAmountOfActiveDisplay - spacesPerDisplay))

    if (( diff > 0 )); then
      destroySpaces $diff $displayId
    elif (( diff < 0)); then
      createSpaces ${diff#-} $displayId # with absolute value
    fi
  done

  moveWindowsToCorrectSpaces
  yabai -m space --focus 1
}

createSpaces() {
  local amount=$1
  local displayId=$2
  echo "display $displayId has too few spacs on it - $amount spaces will be created!" 
  for i in {1..$amount}
  do
    yabai -m space --create
  done
}

destroySpaces() {
  local amount=$1
  local displayId=$2
  local spacesOnCurrentDisplay=($(yabai -m query --displays --display $displayId | jq ".spaces" | sed -e 's/\[//g' -e 's/\]//g' -e 's/\,/ /g'))
  local amountOfSpacesOnCurrentDisplay=${#spacesOnCurrentDisplay[@]}
  local destroyTo=$((amountOfSpacesOnCurrentDisplay - amount + 1))
  echo "display $displayId has following spaces on it: $spacesOnCurrentDisplay, the last $amount will be destroyed!"
  for i in {$amountOfSpacesOnCurrentDisplay..$destroyTo}
  do
    local nextSpaceToDestroy=$spacesOnCurrentDisplay[$i]
    echo "destroy space: $nextSpaceToDestroy on display $displayId"
    yabai -m space --destroy $nextSpaceToDestroy
  done
}

focusDisplay() {
  local displayId=$1
  yabai -m display --focus $displayId
}

moveWindowsToCorrectSpaces() {
  # Assoziatives Array mit Namen und Space
  for key space in ${(kv)apps}; do
   local idsAsString=$(yabai -m query --windows | jq -c ".[] | select(.app | contains($key)) | .id")
   local idsAsString="${idsAsString//[^0-9]/\n}" 
   local window_ids=("${(@s/\n/)idsAsString}") #" # this hash is only because of lsp problems

    # echo "$key $window_ids"
    for window_id in "${window_ids[@]}" 
    do
      # move window to space
      yabai -m window $window_id --space $space
    done
  done
}

start
