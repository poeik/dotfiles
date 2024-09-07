return {
  'christoomey/vim-tmux-navigator',
  config = function()
    vim.keymap.set("n","<C-w>h", vim.cmd.TmuxNavigateLeft, { silent = true })
    vim.keymap.set("n","<C-w>j", vim.cmd.TmuxNavigateDown, { silent = true })
    vim.keymap.set("n","<C-w>k", vim.cmd.TmuxNavigateUp, { silent = true })
    vim.keymap.set("n","<C-w>l", vim.cmd.TmuxNavigateRight, { silent = true })
    vim.keymap.set("n","<C-w>w", vim.cmd.TmuxNavigatePrevious, { silent = true })
  end
}
