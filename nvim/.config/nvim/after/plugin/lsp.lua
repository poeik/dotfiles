local lsp = require('lsp-zero')
local lspconfig = require('lspconfig')

lsp.preset({
	sign_icons = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = '»'
  },
  float_border = 'rounded',
  call_servers = 'local',
  configure_diagnostics = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = {
    preserve_mappings = false,
    omit = {},
  },
  manage_nvim_cmp = {
    set_sources = 'recommended',
    set_basic_mappings = true,
    set_extra_mappings = false,
    use_luasnip = true,
    set_format = true,
    documentation_window = true,
  },
}) -- presets documentation: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#recommended

lsp.skip_server_setup({'eslint', 'ltex'}) -- servers in this list won't be setup automatically. for each of them .setup has to be called individually

lspconfig.eslint.setup({
  on_attach = function(client, bufnr)
    -- fix all autofixables on save
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = "EslintFixAll",
    })
  end,
})

-- tsserver shows always two definitions for react components. this fixes it
local tsHandlers = {
    ["textDocument/definition"] = function(_, result, params)
        local util = require("vim.lsp.util")
        if result == nil or vim.tbl_isempty(result) then
            -- local _ = vim.lsp.log.info() and vim.lsp.log.info(params.method, "No location found")
            return nil
        end

        if vim.tbl_islist(result) then
            -- this is opens a buffer to that result
            -- you could loop the result and choose what you want
            util.jump_to_location(result[1], "utf-8")

            if #result > 1 then
                local isReactDTs = false
                ---@diagnostic disable-next-line: unused-local
                for key, value in pairs(result) do
                    if string.match(value.targetUri, "react/index.d.ts") then
                        isReactDTs = true
                        break
                    end
                end
            end
        else
            util.jump_to_location(result, "utf-8")
        end
    end,
}

lspconfig.tsserver.setup({
  handlers = tsHandlers
})

lspconfig["ltex"].setup({
  settings = {
    ltex = {
      language = "en-GB",
      dictionary = {
        ['en-GB'] = {"JSDoc", "Kolibri", "precomputed", "subproblem" }
      },
      additionalRules = {
        languageModel = '~/ngrams/',
     },
    }
  }
})

local cmp = require('cmp')
local cmp_select = {behavior = cmp.SelectBehavior.Select}
local cmp_mappings = lsp.defaults.cmp_mappings({
  ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
  ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
  ['<C-y>'] = cmp.mapping.confirm({ select = true }),
  ['<Enter>'] = cmp.mapping.confirm({ select = true }),
  ["<C-Enter>"] = cmp.mapping.complete(),
  ['<Tab>'] = {
    i = cmp.config.disable, -- disble tab in insert mode, use <C-p> for that!
    c = cmp.config.disable
  },
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
  -- vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)

  vim.keymap.set('n', '<leader>gd', function()
    vim.cmd('wincmd v')
    vim.lsp.buf.definition()
  end, { noremap=true, silent=true })
end)

lsp.setup()
