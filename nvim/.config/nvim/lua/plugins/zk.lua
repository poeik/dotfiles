return {
  "zk-org/zk-nvim",
  config = function()
    require("zk").setup({
      picker = "telescope",

      lsp = {
        config = {
          cmd = { "zk", "lsp" },
          name = "zk",
        },
        -- automatically attach buffers in a zk notebook that match the given filetypes
        auto_attach = {
          enabled = true,
          filetypes = { "markdown" },
        },
      },
    })
    -- if we are in a zk folder:
    if require("zk.util").notebook_root(vim.fn.expand('%:p')) ~= nil then

      local notebookRoot = require("zk.util").notebook_root(vim.fn.expand('%:p'))
      local notesDir = notebookRoot .. "/notes"
      local meetingsDir = notebookRoot .. "/meetings"

      local newNote = function (n)
        local title = vim.fn.input('Title: ')
        local cmd   = string.format("ZkNew { dir = %q, title = %q }", n, title)
        vim.cmd(cmd)
      end

      local newNoteFromTitle = function (n)
        return "<Cmd>'<,'>ZkNewFromTitleSelection { dir = '" .. n .. "', edit = false }<CR>"
      end

      local newNoteFromContent = function (n)
        return "<Cmd>'<,'>ZkNewFromContentSelection{ dir = '" .. n .. "', title = vim.fn.input('Title: '), edit = false  }<CR>"
      end

      vim.keymap.set('n', '<leader>zn', function() newNote(notesDir) end,
        { desc = "ZkNew in notes group", noremap = true, silent = false }
      )

      vim.keymap.set('v', '<leader>znt', newNoteFromTitle(notesDir),
        { desc = "New note in notes group from selected title", noremap = true, silent = false }
      )

      vim.keymap.set('v', '<leader>znc', newNoteFromContent(notesDir),
        { desc = "New note in notes group from selected content", noremap = true, silent = false }
      )

      vim.keymap.set('n', '<leader>zm', function() newNote(meetingsDir) end,
        { desc = "ZkNew in meetings group", noremap = true, silent = false }
      )

      vim.keymap.set('v', '<leader>zmt', newNoteFromTitle(meetingsDir),
        { desc = "New note in meetings group from selected title", noremap = true, silent = false }
      )

      vim.keymap.set('v', '<leader>zmc', newNoteFromContent(meetingsDir),
        { desc = "New note in meetings group from selected content", noremap = true, silent = false }
      )

      vim.keymap.set("n", "<leader>zb", "<Cmd>ZkBacklinks<CR>", { desc = "Open notes linking to the current buffer", noremap = true, silent = false })
      -- Alternative for backlinks using pure LSP and showing the source context.
      --map('n', '<leader>zb', '<Cmd>lua vim.lsp.buf.references()<CR>', opts)
      -- Open notes linked by the current buffer.
      vim.keymap.set("n", "<leader>zl", "<Cmd>ZkLinks<CR>", { desc = "Open notes linked by the current buffer", noremap = true, silent = false })

      vim.api.nvim_set_keymap("n", "<leader>zt", "<Cmd>ZkTags<CR>",
        { desc = "Open notes associated with the selected tags.", noremap = true, silent = false })
      vim.api.nvim_set_keymap("n", "<leader>zf", "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>",
        { desc = "Search for the notes matching a given query.", noremap = true, silent = false })
      vim.api.nvim_set_keymap("v", "<leader>zf", ":'<,'>ZkMatch<CR>",
        { desc = "Search for the notes matching the current visual selection.", noremap = true, silent = false })
    end
  end
}

