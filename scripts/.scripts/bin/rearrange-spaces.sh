#!/usr/bin/env sh

# the index is the amount of attached displays, the value the amount of spaces 
# per display
declare -A spaceAmount
spaceAmount[1]=9
spaceAmount[2]=4
spaceAmount[3]=3

maxTries=1
declare -A apps
# get windows using yabai -m query --windows | jq
# Code
apps["iTerm2"]=1
apps["Alacritty"]=1
apps["IntelliJ IDEA"]=1
apps["CLion"]=1

# utilities
apps["Google Chrome"]=2
apps["Notion"]=7
apps["Obsidian"]=7
apps["Finder"]=3
apps["Preview"]=3
apps["Spotify"]=4

# messaging
apps["Microsoft Outlook"]=6
apps["Microsoft Teams"]=5
apps["Slack"]=5

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
  # Assoziatives Array mit Namen und Space
  for key space in ${(kv)apps}; do
   local idsAsString=$(yabai -m query --windows | jq -c ".[] | select(.app | contains($key)) | .id")
   local idsAsString="${idsAsString//[^0-9]/\n}" 
   local window_ids=("${(@s/\n/)idsAsString}") #"

    # echo "$key $window_ids"
    for window_id in "${window_ids[@]}" 
    do
      # move window to space
      if [[ -n $window_id ]]; then
        yabai -m window $window_id --space $space
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
