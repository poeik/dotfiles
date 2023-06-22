vim.cmd( [[ 
  call nvimhs#start('/Users/wysstobi/workspaces/fhnw/active/fprod/snips-nvim', 'snips', []) 
]])

vim.keymap.set("n", "<F5>",
  function()
    vim.cmd([[ call nvimhs#compileAndRestart('snips') ]])
    print("recompiling...")
  end
)

-- get snippets
vim.keymap.set("n", "<C-s>", ":Snips<CR>")
