local lspconfig = require("lspconfig")
-- load Frege nightly ls for test projects
-- load new Frege stable ls for all other projects
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()

    local cwd = vim.fn.getcwd()
    local nightly_paths = {
      vim.fn.expand("~") .. "/workspaces/mse/project8/TestFregeLS",
      -- extend as we go
    }
    if vim.tbl_contains(nightly_paths, cwd) then
      ConfigureFregeNightly()
    else
      ConfigureFregeStable()
    end
  end,
})

ConfigureFregeNightly = function()
  print("frege-ls-nighly loaded")

  require('lspconfig.configs').new_frege_nightly = {
    default_config = {
      cmd = { "java", "-Xss4m", "-jar", vim.fn.expand("~") .. "/workspaces/mse/frege/utils/new-frege-lsp-stable/frege-lsp.jar", vim.fn.expand("~") .. "/workspaces/mse/project8/frege-lsp/log.txt" },
      name = "new Frege LS (nightly)",
      filetypes = { 'frege' },
      root_dir = lspconfig.util.root_pattern("build.gradle", "Makefile"),
      settings = {},
    }
  }

  lspconfig.new_frege_nightly.setup {}
end

ConfigureFregeStable = function()
  print("frege-ls loaded")

  require('lspconfig.configs').new_frege_ls = {
    default_config = {
      cmd = { "java", "-Xss4m", "-jar", vim.fn.expand("~") .. "/workspaces/mse/frege/utils/new-frege-lsp-stable/frege-lsp.jar", vim.fn.expand("~") .. "/workspaces/mse/frege/utils/new-frege-lsp-stable/log.txt"},
      name = "new Frege LS",
      filetypes = { 'frege' },
      root_dir = lspconfig.util.root_pattern("build.gradle", "Makefile"),
      settings = {},
    }
  }

  lspconfig.new_frege_ls.setup {}
end
