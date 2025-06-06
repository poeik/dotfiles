return {
  "theprimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    -- add files to harpoon and quick access them
    -- when harpoon has been opened using ctrl+e files can be manipulated as if it were a normal file opened in vim
    local harpoon = require("harpoon")
    harpoon:setup({
        menu = {
            width = vim.api.nvim_win_get_width(0) - 80,
        }
    })

    vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = 'add file to harpoon' })
    vim.keymap.set("n", "<leader>e", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = 'open harpoon files' })

    vim.keymap.set("n", "<C-q>", function() harpoon:list():select(1) end, { desc = 'select first harpoon file' })
    vim.keymap.set("n", "<C-t>", function() harpoon:list():select(2) end, { desc = 'select second harpoon file' })
    vim.keymap.set("n", "<C-n>", function() harpoon:list():select(3) end, { desc = 'select third harpoon file' })
    vim.keymap.set("n", "<C-s>", function() harpoon:list():select(4) end, { desc = 'select fourth harpoon file' })
  end
}
