-- this file contains lsp server setups for mason-lspconfig
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
    local lspconfig = require('lspconfig')

    ---@diagnostic disable-next-line: unused-local
    local lsp_attach = function(_client, bufnr)
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

    -- custom lsp setups
    local purescriptls = function ()
      lspconfig.purescriptls.setup({
        -- Your personal on_attach function referenced before to include
        -- keymaps & other ls options
        on_attach = function(client, _)
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
    end

    local eslint = function ()
      lspconfig.eslint.setup({
        on_attach = function(_, bufnr)
          -- fix all autofixables on save
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })
    end

    local ts_ls = function ()
        lspconfig.ts_ls.setup({
          handlers = {
            -- ts_ls shows always two definitions for react components. this fixes it
            ["textDocument/definition"] = function(_, result, _)
              local util = require("vim.lsp.util")
              if result == nil or vim.tbl_isempty(result) then
                -- local _ = vim.lsp.log.info() and vim.lsp.log.info(params.method, "No location found")
                return nil
              end

              if vim.islist(result) then
                -- this is opens a buffer to that result
                -- you could loop the result and choose what you want
                util.jump_to_location(result[1], "utf-8")

                if #result > 1 then
                  ---@diagnostic disable-next-line: unused-local
                  for key, value in pairs(result) do
                    if string.match(value.targetUri, "react/index.d.ts") then
                      break
                    end
                  end
                end
              else
                util.jump_to_location(result, "utf-8")
              end
            end,
          }
        })
      end

      local lua_ls = function()
        lspconfig.lua_ls.setup({
          on_init = function(client)
            lsp_zero.nvim_lua_settings(client, {})
          end,
        })
      end

    require('mason-lspconfig').setup({
      ensure_installed = {'lua_ls', 'tsserver'},
      handlers = {
        function(server_name) lspconfig[server_name].setup({}) end,
        purescriptls = purescriptls,
        eslint       = eslint,
        tsserver     = ts_ls,
        lua_ls       = lua_ls
      },
    })

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
          i = cmp.config.disable, -- disble tab in insert mode, use <C-n> for that!
          c = cmp.config.disable
        },
      })
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

