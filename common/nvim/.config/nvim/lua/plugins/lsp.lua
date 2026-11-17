return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
  },
  config = function()
    require('mason').setup({})
    require('mason-lspconfig').setup({
      automatic_enable = true,
      ensure_installed = {
        'lua_ls',
        'ts_ls',
        'rust_analyzer',
        'marksman',
        'tinymist',
      },
    })

    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('UserLspConfig', {}),
      callback = function(ev)
        local opts = { buffer = ev.buf, remap = false }

        -- vim's built-in gd/<C-]> don't use the LSP (reuse_win jumps to an already open window)
        vim.keymap.set("n", "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, { buffer = ev.buf, desc = '[G]oto [D]efinition' })
        -- natively: gri
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
        -- natively: grr (quickfix list), the telescope picker has preview and filtering
        vim.keymap.set("n", "gr", require('telescope.builtin').lsp_references, opts)
        -- natively: K (default since 0.10), border comes from 'winborder'
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        -- no native mapping, <leader>ws (telescope) is the better picker
        vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
        -- natively: <C-w>d
        vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
        -- natively: ]d / [d (vim.diagnostic.goto_* is deprecated in favour of jump)
        vim.keymap.set("n", "<leader>2", function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
        vim.keymap.set("n", "<leader>3", function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
        -- natively: gra
        vim.keymap.set({"n", "v"}, "<leader><CR>", vim.lsp.buf.code_action, opts)
        -- natively: grr
        vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
        -- natively: grn
        vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
        -- natively: <C-s> in insert mode
        -- vim.keymap.set({"n", "i"}, "<C-i>", vim.lsp.buf.signature_help, opts)

        -- no native equivalent (<C-w>] splits via tags, not the LSP)
        vim.keymap.set('n', '<leader>gd', function()
          vim.cmd('wincmd v')
          vim.lsp.buf.definition()
        end, { buffer = ev.buf, noremap = true, silent = true })
      end,
    })
  end,
}
