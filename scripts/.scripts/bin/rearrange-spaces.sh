#!/usr/bin/env sh

# the index is the amount of attached displays, the value the amount of spaces 
# per display
declare -a spaceAmount
spaceAmount[1]=9
spaceAmount[2]=4
spaceAmount[3]=3

maxTries=1

declare -a apps

# Funktion zum Hinzufügen eines App-Objekts
configure_app() {
    local app_name="$1"
    local title="$2"
    local desktop="$3"
    
    # Speichere die Daten als Array
    apps+="$app_name,$title,$desktop"
}

# Code
configure_app "Alacritty" "" 1
configure_app "IntelliJ IDEA" "" 1

# utilities
configure_app "Google Chrome" "" 2
configure_app "Notion" "" 7
configure_app "Obsidian" "" 7
configure_app "Alacritty" "vault" 7
configure_app "Alacritty" "_tmp" 3
configure_app "Finder" "" 3
configure_app "Preview" "" 3
configure_app "Spotify" "" 4

# messaging
configure_app "Microsoft Outlook" "" 6
configure_app "Microsoft Teams" "" 5
configure_app "Slack" "" 5

start () {
  # just that we do not run in an endless recursion
  local currentTry=$1
  if [[ $currentTry -eq $maxTries ]]; then 
    echo "Could not fix spaces in $maxTries attempts, exiting."
    return
  fi

  # get current space to focus back on it later
  local currentSpace=$(yabai -m query --spaces --space | jq .index)

  local displayAmount=$(yabai -m query --displays | jq -c "length")
  if [[ ! ($displayAmount -eq 1 || $displayAmount -eq 2 || $displayAmount -eq 3) ]]; then 
    echo "Behaviour for $displayAmount is not defined, exit"
    return 0
  fi
  echo "Currently are $displayAmount display attached."

  local spacesPerDisplay=${spaceAmount[$displayAmount]}

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

  local everythingOk=$(checkEverythingIsOk)

  if [[ $everythingOk -eq 1 ]]; then
    # something went wrong, start all over
    currentTry=$((currentTry + 1))
    start $currentTry
  else
    yabai -m space --focus $currentSpace
  fi
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
  for config in "${apps[@]}"; do
    IFS=',' read -r app title desktop <<< "${config}"
    if [[ -n "$title" ]]; then
      local idsAsString=$(yabai -m query --windows | jq -c ".[] | select((.app | contains(\"$app\")) and (.title | contains(\"$title\"))) | .id")
    else
      local idsAsString=$(yabai -m query --windows | jq -c ".[] | select(.app | contains(\"$app\")) | .id")
    fi    

    local idsAsString="${idsAsString//[^0-9]/\n}" 
    local window_ids=("${(@s/\n/)idsAsString}") #"

    for window_id in "${window_ids[@]}" 
    do
      # move window to space
      if [[ -n $window_id ]]; then
        # echo "yabai -m window $window_id --space $desktop"
        yabai -m window $window_id --space $desktop
      fi
    done
  done
}

checkEverythingIsOk() {
  # currently only the maount of spaces per display is checked
  local displayAmount=$(yabai -m query --displays | jq -c "length")
  local spacesPerDisplay=${spaceAmount[$displayAmount]}
  local everythingOk=0

  for i in {1..$displayAmount}
  do
    local displayId=$i
    focusDisplay $displayId
    local currentSpaceAmountOfActiveDisplay=$(yabai -m query --displays --display | jq ".spaces | length")
    local diff=$((currentSpaceAmountOfActiveDisplay - spacesPerDisplay))

    if [[ diff -ne 0 ]]; then
      everythingOk=1
      break
    fi
  done
  echo $everythingOk 
}

start 0
