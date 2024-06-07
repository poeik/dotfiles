-- contains all plugins that do not need additional config
return {
  -- color schemes, wysstobi/colors.lua specifies the color scheme config
  "folke/tokyonight.nvim",
  "rebelot/kanagawa.nvim",
  "tpope/vim-commentary",
  "towolf/vim-helm",
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  'nvim-tree/nvim-web-devicons', -- for telescope file icons
}
