-- contains all plugins that do not need additional config
return {
  -- color schemes, wysstobi/colors.lua specifies the color scheme config
  "folke/tokyonight.nvim",
  "rebelot/kanagawa.nvim",
  -- commentary keyboard shortcuts
  "tpope/vim-commentary",

  'nvim-tree/nvim-web-devicons', -- for telescope file icons
  { "ryanoasis/vim-devicons", priority = 100 } -- for nerdtree file icons, load it first
}
