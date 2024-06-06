return {
  "nvim-tree/nvim-tree.lua",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    require("nvim-tree").setup {
      renderer = {
        group_empty = true, -- stack single file folders
      },
      vim.keymap.set("n","<leader>pt", function()
        vim.cmd.NvimTreeToggle()
        vim.cmd("wincmd p")
      end),
      vim.keymap.set("n","<leader>pf", function()
        vim.cmd.NvimTreeFindFile()
        vim.cmd("wincmd p")
      end),
      vim.keymap.set("n","<leader>pv", vim.cmd.NvimTreeFocus)
    }
  end,
}

