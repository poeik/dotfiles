return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      "<leader>f",
      function() require("conform").format({ async = true, lsp_fallback = true }) end,
      mode = { "n", "v" },
      desc = "[F]ormat buffer/selection",
    },
  },
  opts = {
    formatters = {
      -- disable if project has no prettier config
      prettier = {
        condition = function(_, ctx)
          return vim.fs.find({
            ".prettierrc", ".prettierrc.json", ".prettierrc.yml", ".prettierrc.yaml",
            ".prettierrc.js", "prettier.config.js", "prettier.config.mjs",
          }, { path = ctx.filename, upward = true })[1] ~= nil
        end,
      },
    },
    formatters_by_ft = {
      javascript = { "prettierd", "prettier", stop_after_first = true },
      typescript = { "prettierd", "prettier", stop_after_first = true },
      javascriptreact = { "prettierd", "prettier", stop_after_first = true },
      typescriptreact = { "prettierd", "prettier", stop_after_first = true },
      json = { "prettierd", "prettier", stop_after_first = true },
      jsonc = { "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd", "prettier", stop_after_first = true },
      markdown = { "prettierd", "prettier", stop_after_first = true },
      html = { "prettierd", "prettier", stop_after_first = true },
      css = { "prettierd", "prettier", stop_after_first = true },
      scss = { "prettierd", "prettier", stop_after_first = true },
      graphql = { "prettierd", "prettier", stop_after_first = true },
      vue = { "prettierd", "prettier", stop_after_first = true },
      scala = { "scalafmt" },
    },
    format_on_save = {
      timeout_ms = 1000,
      lsp_fallback = true, -- if no formatter matches, fall back to the LSP's own formatter
    },
  },
}
