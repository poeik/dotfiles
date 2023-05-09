# more settings at: https://apple.stackexchange.com/questions/14001/how-to-turn-off-all-animations-on-os-x/63477#63477
# Disable animations when opening and closing windows.
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# Accelerated playback when adjusting the window size.
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

# opening and closing quick look window
defaults write -g QLPanelAnimationDuration -float 0.001



