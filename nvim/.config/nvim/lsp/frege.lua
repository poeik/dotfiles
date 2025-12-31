return {
    cmd = { "sh", vim.fn.expand("~") .. "/workspaces/mse/project8/frege-ls/build/install/frege-ls/bin/frege-ls" },
    name = "Frege Language Server",
    filetypes = { 'frege' },
    root_markers = { "build.gradle", "Makefile" },
    settings = {},
    on_attach = function(_, bufnr)
        vim.keymap.set("n", "<leader>rr", function()
          vim.cmd("! gradle compileFrege && gradle installDist")
        end, { buffer = bufnr, silent = true })

        vim.keymap.set("n", "<leader>rb", function()
          vim.cmd("! gradle compileFrege")
        end, { buffer = bufnr, silent = true })

        vim.keymap.set("n", "<leader>rt", function()
          vim.cmd("! gradle testFrege")
        end, { buffer = bufnr, silent = true })
      end
}
