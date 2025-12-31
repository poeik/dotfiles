-- this file contains LSP server setups for mason-lspconfig
return {
  "VonHeikemen/lsp-zero.nvim",
  branch = 'v4.x',
  dependencies = {
    -- LSP Support
    'neovim/nvim-lspconfig',
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',

    -- Autocompletion
    'hrsh7th/nvim-cmp',       -- provides general auto completion
    'hrsh7th/cmp-nvim-lsp',   -- provides auto completion for lsp
    'hrsh7th/cmp-buffer',     -- autocompletion for buffer words
    'hrsh7th/cmp-path',       -- autocompletion for file system paths
    'hrsh7th/cmp-nvim-lua',

    -- Snippets
    'L3MON4D3/LuaSnip',
  },
  config = function()
    local lsp_zero = require('lsp-zero')

    ---@diagnostic disable-next-line: unused-local
    local lsp_attach = function(_client, bufnr)
      local opts = {buffer = bufnr, remap = false}

      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gr", require('telescope.builtin').lsp_references, opts)
      vim.keymap.set("n", "K", function() vim.lsp.buf.hover { border = "single" } end, opts)
      vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
      vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
      vim.keymap.set("n", "<leader>2", vim.diagnostic.goto_next, opts)
      vim.keymap.set("n", "<leader>3", vim.diagnostic.goto_prev, opts)
      vim.keymap.set({"n", "v"}, "<leader><CR>", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
      -- vim.keymap.set({"n", "i"}, "<C-i>", vim.lsp.buf.signature_help, opts)

      vim.keymap.set('n', '<leader>gd', function()
        vim.cmd('wincmd v')
        vim.lsp.buf.definition()
      end, { noremap=true, silent=true })

      lsp_zero.default_keymaps({buffer = bufnr})
    end

    lsp_zero.extend_lspconfig({
      capabilities = require('cmp_nvim_lsp').default_capabilities(),
      lsp_attach = lsp_attach,
      float_border = 'rounded',
      sign_text = {
        error = '✘',
        warn  = '▲',
        hint  = '⚑',
        info  = '»',
      },
    })
    require('mason').setup({})

    -- auto completion settings
    local cmp = require('cmp')
    local cmp_select = {behavior = cmp.SelectBehavior.Select}

    -- auto completion sources
    cmp.setup({
      sources = {
        -- see plugin dependencies above
        {name = 'path'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lua'},
        {name = 'luasnip', keyword_length = 2},
        {name = 'buffer', keyword_length = 3},
      },
      formatting = lsp_zero.cmp_format({}), -- formatting of completion window
      mapping = cmp.mapping.preset.insert({
        ['<C-p>'] = cmp.mapping.select_prev_item(cmp_select),
        ['<C-n>'] = cmp.mapping.select_next_item(cmp_select),
        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
        ['<Enter>'] = cmp.mapping.confirm({ select = true }),
        ['<Tab>'] = {
          i = cmp.config.disable, -- disable tab in insert mode, use <C-n> for that!
          c = cmp.config.disable
        },
      })
    })
  end,
  priority = 1
}


