require('telescope').setup({
  defaults = {
    file_ignore_patterns = { 'node_modules', '.git' }
  }
})

local builtin = require('telescope.builtin')
local themes = require('telescope.themes')
-- indicates whether hidden files should be shown
local hidden = false
vim.keymap.set('n', '<C-p>', builtin.git_files, {}) -- only looks for files managed by git
vim.keymap.set('n', '<leader>sf', function() builtin.find_files({hidden = hidden}) end, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', function() builtin.live_grep({hidden = hidden}) end, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

vim.keymap.set('n', '<leader>hf', function()
  hidden = not hidden
  print("Show hidden files: " .. tostring(hidden))
end, { desc = 'Swap search [H]idden [F]iles' })

vim.keymap.set('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(themes.get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc ='[/] Fuzzily search in current buffer' })
