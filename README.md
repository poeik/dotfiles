# dotfiles

## Setup

My personal dotfiles. `stow` is used to create symlinks in the home directory.
_Note:_ `stow  --target=$HOME */ --ignore stow-ignore` to stow to the home directory
_Note 2:_ use `stow --delete` to remove the generated symlinks


## Additional tools needed to setup the terminal

- Install stow using `brew install stow`
- Install [ohmyz.sh](https://ohmyz.sh/#install)
- Replace the newly created `.zshrc` with the content of `.zshrc.pre-oh-my-zsh`
  using `mv .zshrc.pre-oh-my-zsh .zshrc`
- Install the zsh plugin manager
  [antigen](https://github.com/zsh-users/antigen) into the user folder using
  `curl -L git.io/antigen > ~/.antigen.zsh`

## Neovim setup

- Install `ripgrep` and `fd` using `brew install ripgrep fd` for telescope to work

## Other important tools

- For tmux sessionizer install `brew install fzf tmux`
- Install JetBrains Mono Nerdfont

## Install spell checkers

Nvim can automatically install spell checker when needed. But some plugin
hinder Nvim to do this. 
To fix this
1. open Nvim like `nvim -u NORC`
2. Set the spell checker to the language you wish to install `:set spelllang=en`
