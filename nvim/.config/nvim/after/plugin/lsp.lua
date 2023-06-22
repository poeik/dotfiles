local lsp = require('lsp-zero')
local lspConfig = require('lspconfig')

lsp.preset('recommended')

lsp.ensure_installed({
  'tsserver',
	'eslint',
  'html'
})

lsp.configure('sumneko_lua', {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
})

lspConfig["ltex"].setup({
  settings = {
    ltex = {
      language = "en-GB",
      dictionary = {
        ['en-GB'] = {"Kolibri", "precomputed", "subproblem" }
      },
      additionalRules = {
        languageModel = '~/ngrams/',
     },
    }
  }
})

--lsp.configure('ltex-ls', {
--    ltex = {
--      enabled = false,
--      language = "de_CH"
--    }
--})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Space>"] = cmp.mapping.complete(),
})


lsp.set_preferences({
	sign_icons = { }
})

lsp.setup_nvim_cmp({
  mapping = cmp_mappings
})
-- commands defined in on_attach are only available when lsp is running on that buffer
-- with that, default vim LST will be used if lst-zero is not available for a file.
lsp.on_attach(function(client, bufnr)
  local opts = {buffer = bufnr, remap = false}

  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "gr", require('telescope.builtin').lsp_references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
  vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
  vim.keymap.set("n", "<leader>2", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>3", vim.diagnostic.goto_prev, opts)
  vim.keymap.set({"n", "v"}, "<leader><CR>", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
  vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)


  vim.diagnostic.config({virtual_text = true})
end)


lsp.setup()
