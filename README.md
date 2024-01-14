# dotfiles

## Setup

My personal dotfiles. `stow` is used to create symlinks in the home directory.
_Note:_ `stow  --target=$HOME */ --ignore stow-ignore` to stow to the home directory
_Note2:_ use `stow --delete` to remove the generated symlinks


## Additional tools needed to setup the terminal

- Install stow using `brew install stow`
- Install [ohmyz.sh](https://ohmyz.sh/#install)
- Replace the newly created `.zshrc` with the content of `.zshrc.pre-oh-my-zsh`
  using `mv .zshrc.pre-oh-my-zsh .zshrc`
- Install the zsh plugin manager
  [antigen](https://github.com/zsh-users/antigen) into the userfolder using
  `curl -L git.io/antigen > ~/.antigen.zsh`

## Neovim setup

- Install [packer.nvim](https://github.com/wbthomason/packer.nvim?tab=readme-ov-file#quickstart)
- Open [packer.lua](nvim/.config/nvim/lua/wysstobi/packer.lua) in `nvim` and
  source it using `:so %`
- Execute `:PackerSync` to install all plugins
- Install `ripgrep` and `fd` using `brew install ripgrep fd` for telescope to work

## Other important tools

- For tmux sessionizer install `brew install fzf tmux`
- Install JetBrains Mono Nerdfont
