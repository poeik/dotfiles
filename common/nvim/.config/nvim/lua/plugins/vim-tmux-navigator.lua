return {
  'christoomey/vim-tmux-navigator',
  config = function()
    vim.keymap.set("n","<C-w>h", vim.cmd.TmuxNavigateLeft, { silent = true, desc = "navigate to left tmux pane" })
    vim.keymap.set("n","<C-w>j", vim.cmd.TmuxNavigateDown, { silent = true, desc = "navigate to lower tmux pane"  })
    vim.keymap.set("n","<C-w>k", vim.cmd.TmuxNavigateUp, { silent = true, desc = "navigate to uppoer tmux pane"  })
    vim.keymap.set("n","<C-w>l", vim.cmd.TmuxNavigateRight, { silent = true, desc = "navigate to right tmux pane"  })
    vim.keymap.set("n","<C-w>w", vim.cmd.TmuxNavigatePrevious, { silent = true, desc = "navigate to previous tmux pane"  })
  end
}
