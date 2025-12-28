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
    local lspconfig = require('lspconfig')

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

    -- custom LSP setups
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
            addSpagoSources = true
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
          -- ts_ls shows always two definitions for react components. This fixes it
          ["textDocument/definition"] = function(_, result, _)
            local util = require("vim.lsp.util")
            if result == nil or vim.tbl_isempty(result) then
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

    local typst_setup = function()
      lspconfig.tinymist.setup({
        on_attach = function(client, bufnr)
          local mainFile = client.config.root_dir .. '/main.typ'

          -- see https://myriad-dreamin.github.io/tinymist/frontend/neovim.html#label-Working%20with%20Multiple-Files%20Projects
          client:exec_cmd({
            title = "pin",
            command = "tinymist.pinMain",
            arguments = { mainFile },
          }, { bufnr = bufnr })

          local opts = function(desc)
            return { desc = desc, buffer = bufnr, remap = false }
          end
          -- run preview
          vim.keymap.set("n", "<leader>rr", function()
            -- open mainfile
            vim.cmd("e " .. mainFile)
            -- run command
            vim.cmd.TypstPreview()
            -- reselect previous buffer
            vim.cmd("buffer " .. bufnr)
          end, opts("Start Typst preview"))
          -- stop preview
          vim.keymap.set("n", "<leader>rc", function()
            -- open mainfile
            vim.cmd("e " .. mainFile)
            -- run command
            vim.cmd.TypstPreviewStop()
            -- reselect previous buffer
            vim.cmd("buffer " .. bufnr)
          end, opts("Stop Typst preview"))
        end,
        offset_encoding = "utf-8",
        settings = {
          formatterMode = "typstyle",
          exportPdf = "onSave",
        },
      })
    end

    local ltex_setup = function()
      lspconfig.ltex.setup({
        filetypes = { "latex", "bib", "markdown", "plaintex", "tex" },
        settings = {
          ltex = {
            enabled = { "latex", "bib", "markdown", "plaintex", "tex" },
          }
        }
      })
    end

    require('mason-lspconfig').setup({
      ensure_installed = {'lua_ls'},
      handlers = {
        function(server_name) lspconfig[server_name].setup({}) end,
        purescriptls = purescriptls,
        eslint       = eslint,
        ts_ls        = ts_ls,
        lua_ls       = lua_ls,
        tinymist     = typst_setup,
        ltex         = ltex_setup
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
          i = cmp.config.disable, -- disable tab in insert mode, use <C-n> for that!
          c = cmp.config.disable
        },
      })
    })

    typst_setup()

    vim.lsp.enable('hls')
  end,
  priority = 1
}


