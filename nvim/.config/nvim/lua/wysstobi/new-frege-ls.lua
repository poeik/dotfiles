local lspconfig = require("lspconfig")

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    ConfigureFregeStable()
  end,
})

ConfigureFregeStable = function()
  require('lspconfig.configs').new_frege_ls = {
    default_config = {
      -- cmd = { "java", "-Xss1024m", "-jar", vim.fn.expand("~") .. "/workspaces/mse/frege/utils/new-frege-lsp-stable/frege-lsp.jar", vim.fn.expand("~") .. "/workspaces/mse/frege/utils/new-frege-lsp-stable/log.txt"},
      cmd = { "sh", vim.fn.expand("~") .. "/workspaces/mse/project8/frege-ls/build/install/frege-ls/bin/frege-ls" },
      name = "new Frege LS",
      filetypes = { 'frege' },
      root_dir = lspconfig.util.root_pattern("build.gradle", "Makefile"),
      settings = {},
    }
  }

  lspconfig.new_frege_ls.setup {
    on_attach = function(client, bufnr)
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
end
