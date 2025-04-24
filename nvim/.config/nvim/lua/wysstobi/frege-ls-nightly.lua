local lspconfig = require("lspconfig")
-- load Frege nightly ls for test projects
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local cwd = vim.fn.getcwd()

    local target_paths = {
      vim.fn.expand("~") .. "/workspaces/mse/project8/TestFregeLS",
      -- extend as we go
    }

    for _, path in ipairs(target_paths) do
      if cwd:find(path) then
        LoadFregeNightly()
        break
      end
    end
  end,
})

LoadFregeNightly = function()
  print("frege-ls-nighly loaded")

  require('lspconfig.configs').new_frege_ls = {
    default_config = {
      cmd = { "java", "-Xss4m", "-jar", "/Users/wysstobi/workspaces/mse/project8/frege-lsp/build/libs/frege-lsp.jar", "/Users/wysstobi/workspaces/mse/project8/frege-lsp/log.txt" },
      name = "new Frege LS",
      filetypes = { 'frege' },
      root_dir = lspconfig.util.root_pattern("build.gradle", "Makefile"),
      settings = {},
    }
  }

  lspconfig.new_frege_ls.setup {}
end
