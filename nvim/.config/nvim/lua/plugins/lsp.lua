return {
  "VonHeikemen/lsp-zero.nvim",
  dependencies = {
  		-- LSP Support
      'neovim/nvim-lspconfig',
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',

      -- Autocompletion
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-nvim-lua',

      -- Snippets
      'L3MON4D3/LuaSnip',
      'rafamadriz/friendly-snippets',
  },
  config = function()

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



    -- commands defined in on_attach are only available when lsp is running on that buffer
    -- with that, default vim LSP will be used if lst-zero is not available for a file.
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

    require('mason').setup({})
    require('mason-lspconfig').setup({
      ensure_installed = {'tsserver'},
      handlers = {
        lsp.default_setup,
      }
    })

    lspconfig.purescriptls.setup({
      -- Your personal on_attach function referenced before to include
      -- keymaps & other ls options
      on_attach = function(client, bufnr)
        -- Stelle sicher, dass Diagnosen bei Textänderung aktualisiert werden
        client.resolved_capabilities.document_formatting = true
      end,
      handlers = {
        ["textDocument/publishDiagnostics"] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics, {
          -- Aktualisiere Diagnosen sofort bei Textänderungen
          update_in_insert = true,
        }
        ),
      },
      settings = {
        purescript = {
          addSpagoSources = true -- e.g. any purescript language-server config here
        }
      },
      flags = {
        debounce_text_changes = 150,
      }
    })

    lspconfig.lua_ls.setup({
      settings = {
        Lua = {
          diagnostics = {
            -- Get the language server to recognize the `vim` global
            globals = {'vim'},
          },
        },
      },
    })

    local cmp = require('cmp')
    local cmp_select = {behavior = cmp.SelectBehavior.Select}

    cmp.setup({
      sources = {
        {name = 'path'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lua'},
        {name = 'luasnip', keyword_length = 2},
        {name = 'buffer', keyword_length = 3},
      },
      formatting = lsp.cmp_format(),
      mapping = cmp.mapping.preset.insert({
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
    })

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

    require('lspconfig.configs').frege_ls = {
      default_config = {
        cmd = {"sh", "/Users/wysstobi/workspaces/mse/frege/utils/frege-lsp-server-4.1.3-alpha/bin/frege-lsp-server"},
        filetypes = {'frege'},
        root_dir = lspconfig.util.root_pattern("settings.gradle", "build.sbt", "Makefile"),
        settings = {},
      },
      commands = {
        FregeRun = {
          function()
            local cmd = string.format('gradle clean runFrege')
            -- vim.cmd(string.format('term %s', cmd))
            local output = vim.fn.system(cmd)
            vim.api.nvim_echo({{output, "Normal"}}, false, {})
          end,
          description = 'Run Frege Code',
        },
        FregeRepl = {
          function()
            local cmd = string.format('eval $(gradle -q clean replFrege)')
            vim.cmd(string.format('term %s', cmd))
          end,
          description = 'Start Frege REPL',
        },
      },
    }
    lspconfig.frege_ls.setup {}


  end,
  priority = 1
}

