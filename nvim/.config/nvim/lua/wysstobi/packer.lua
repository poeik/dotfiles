-- contains all extensions
-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
-- vim.cmd [[packadd packer.nvim]]
-- 
-- return require('packer').startup(function(use)
  -- Packer can manage itself
  -- fuzzyfinder
  --use {
  --	'nvim-telescope/telescope.nvim', tag = '0.1.5',
  --	requires = { {'nvim-lua/plenary.nvim'} }
  --}
  -- color scheme
  --
  -- use { "folke/tokyonight.nvim"}
  -- use { 'rebelot/kanagawa.nvim' }

  -- use('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'}) -- syntax highlighting for different languages
  -- use('theprimeagen/harpoon') -- quick access files
  -- use('mbbill/undotree') -- access filehistory
  -- use('tpope/vim-fugitive') -- git support
  -- use('ThePrimeagen/vim-be-good') -- vim learning game (start using :VimBeGood)
  -- use('ryanoasis/vim-devicons')
  -- use('lervag/vimtex')

  -- use 'nvim-tree/nvim-web-devicons'
  --use 'tpope/vim-commentary'
  --use('neovimhaskell/nvim-hs.vim')

  -- adds better lsp support. Uses Mason in background.
  -- use {
  -- 	'VonHeikemen/lsp-zero.nvim',
  -- 	requires = {
  -- 		-- LSP Support
  -- 		{'neovim/nvim-lspconfig'},
  -- 		{'williamboman/mason.nvim'},
  -- 		{'williamboman/mason-lspconfig.nvim'},

  -- 		-- Autocompletion
  -- 		{'hrsh7th/nvim-cmp'},
  -- 		{'hrsh7th/cmp-buffer'},
  -- 		{'hrsh7th/cmp-path'},
  -- 		{'saadparwaiz1/cmp_luasnip'},
  -- 		{'hrsh7th/cmp-nvim-lsp'},
  -- 		{'hrsh7th/cmp-nvim-lua'},

  -- 		-- Snippets
  -- 		{'L3MON4D3/LuaSnip'},
  -- 		{'rafamadriz/friendly-snippets'},
  -- 	}
  -- }
  -- statusline
  -- use {
  --   'nvim-lualine/lualine.nvim',
  --   requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  -- }

  -- navigation utilities
  -- use('preservim/nerdtree')
  --   use('christoomey/vim-tmux-navigator')
  --   use {'stevearc/dressing.nvim'}z
-- 
-- end)
