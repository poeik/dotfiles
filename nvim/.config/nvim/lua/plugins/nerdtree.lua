return {
  "preservim/nerdtree",
  config = function()
    vim.keymap.set("n","<leader>pt", function() 
      vim.cmd.NERDTreeToggle()
      vim.cmd("wincmd p")
    end)

    vim.keymap.set("n","<leader>pf", function()
      vim.cmd.NERDTreeFind()
      vim.cmd("wincmd p")
    end)

    vim.keymap.set("n","<leader>pv", vim.cmd.NERDTreeFocus)
  end
}

