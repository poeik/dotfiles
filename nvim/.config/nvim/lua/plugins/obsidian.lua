return {
  "epwalsh/obsidian.nvim",
  version = "*",  -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = "markdown",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
    "nvim-telescope/telescope.nvim",
    "nvim-treesitter"
  },
  opts = {
    workspaces = {
      {
        name = "vault",
        path = "~/workspaces/obsidian/vault/",
      },
    },
    -- Where to put new notes. Valid options are
    --  * "current_dir" - put new notes in same directory as the current buffer.
    --  * "notes_subdir" - put new notes in the default notes subdirectory.
    -- new_notes_location = "notes_subdir",
    note_id_func = function(title)
      local filename = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        filename = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          filename = filename .. string.char(math.random(65, 90))
        end
      end
      return filename
    end,

    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      vim.fn.jobstart({"open", url})
    end,
    follow_img_func = function(img)
      vim.fn.jobstart { "qlmanage", "-p", img }
    end,
    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
      name = "telescope.nvim",
      -- Optional, configure key mappings for the picker. These are the defaults.
      -- Not all pickers support all mappings.
      note_mappings = {
        -- Create a new note from your query.
        new = "<C-x>",
        -- Insert a link to the selected note.
        insert_link = "<C-l>",
      },
      tag_mappings = {
        -- Add tag(s) to current note.
        tag_note = "<C-x>",
        -- Insert a tag at the current location.
        insert_tag = "<C-l>",
      },
    },
  },
  init = function ()
    vim.keymap.set("n", "gd", function()
      if require("obsidian").util.cursor_on_markdown_link() then
        return "<cmd>ObsidianFollowLink<CR>"
      else
        return "gd"
      end
    end, { noremap = false, expr = true })
  end,
  -- available commands: https://github.com/epwalsh/obsidian.nvim?tab=readme-ov-file#commands
  keys = {
    {'<leader>oo', ':ObsidianOpen<CR>', desc = ""},
    {'<leader>on', ':ObsidianNew<CR>', desc = ""},
    {'<leader>of', ':ObsidianQuickSwitch<CR>', desc = ""},
    {'<leader>or', ':ObsidianRename<CR>', desc = ""},
    {'<leader>oi', ':ObsidianPasteImg<CR>', desc = ""},
  },
  priority = 500 -- needs to be loaded after lsp, so that the gd overwrite works
}
