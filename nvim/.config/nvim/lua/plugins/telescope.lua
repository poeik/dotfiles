-- colors every element after two tabs in comment color
vim.api.nvim_create_autocmd("FileType", {
	pattern = "TelescopeResults",
	callback = function(ctx)
		vim.api.nvim_buf_call(ctx.buf, function()
			vim.fn.matchadd("TelescopeParent", "\t\t.*$")
			vim.api.nvim_set_hl(0, "TelescopeParent", { link = "Comment" })
		end)
	end,
})

return {
  'nvim-telescope/telescope.nvim', tag = '0.1.5',
  dependencies = {
    -- ui-select sets enables vim.ui.select to telescope
    'nvim-telescope/telescope-ui-select.nvim',
    'nvim-lua/plenary.nvim',
  },
  config = function()
    local telescope = require('telescope')
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local builtin = require('telescope.builtin')
    local themes = require('telescope.themes')

    -- sends either all files, or if files are selected, all selected files to qf list
    local smart_send_to_qflist = function(prompt_bufnr)
        local picker = action_state.get_current_picker(prompt_bufnr)
        local multi_selection = picker:get_multi_selection()

        if #multi_selection > 0 then
            -- only send selected
            actions.send_selected_to_qflist(prompt_bufnr)
        else
            -- send all files
            actions.send_to_qflist(prompt_bufnr)
        end
        actions.open_qflist(prompt_bufnr)
    end


    local display_telescope_file = function(_, path)
          local tail = vim.fs.basename(path)
	        local parent = vim.fs.dirname(path)
          return string.format("%s\t\t(%s)", tail, parent)
    end


    telescope.setup({
      extensions = {
        ['ui-select'] = { themes.get_dropdown {} }
      },
      defaults = {
        -- Format path as "file.txt (path\to\file\)"              
        path_display = display_telescope_file,
        file_ignore_patterns = { 'elm-stuff', 'node_modules', '.git' },
        mappings = {
          i = { ["<C-q>"] = smart_send_to_qflist, },
          n = { ["<C-q>"] = smart_send_to_qflist, },
        },
      },
      pickers = {
        lsp_references = {
          jump_type = "vsplit",
          show_line = false,
        }
      }
    })

    telescope.load_extension('ui-select')

    -- indicates whether hidden files should be shown
    local hidden = false

    vim.keymap.set('n', '<leader>g', builtin.git_files, {}) -- only looks for files managed by git
    vim.keymap.set('n', '<leader>sf', function() builtin.find_files({hidden = hidden}) end, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.lsp_document_symbols, { desc = '[S]earch [S]ymbols' })
    vim.keymap.set('n', '<leader>ws', builtin.lsp_workspace_symbols, { desc = '[W]orkspace [S]ymbols' })
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', function() builtin.live_grep({hidden = hidden}) end, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })


    vim.keymap.set('n', '<leader>hf', function()
      hidden = not hidden
      print("Show hidden files: " .. tostring(hidden))
    end, { desc = 'Swap search [H]idden [F]iles' })

    vim.keymap.set('n', '<leader>x', function()
      builtin.current_buffer_fuzzy_find(themes.get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc ='[/] Fuzzily search in current buffer' })
  end
}
