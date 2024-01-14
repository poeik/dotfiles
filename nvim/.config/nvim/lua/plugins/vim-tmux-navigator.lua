return {
  'christoomey/vim-tmux-navigator',
  config = function()
    vim.keymap.set("n","<C-h>", vim.cmd.TmuxNavigateLeft, { silent = true })
    vim.keymap.set("n","<C-j>", vim.cmd.TmuxNavigateDown, { silent = true })
    vim.keymap.set("n","<C-k>", vim.cmd.TmuxNavigateUp, { silent = true })
    vim.keymap.set("n","<C-l>", vim.cmd.TmuxNavigateRight, { silent = true })
  end
}
