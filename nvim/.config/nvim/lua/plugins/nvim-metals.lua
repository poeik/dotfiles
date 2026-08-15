local map = vim.keymap.set

return {
  "scalameta/nvim-metals",
  dependencies = {
    "nvim-lua/plenary.nvim",
    {
      "j-hui/fidget.nvim",
      opts = {},
    },
    {
      "mfussenegger/nvim-dap",
      config = function(self, opts)
        -- Debug settings if you're using nvim-dap
        local dap = require("dap")

        dap.configurations.scala = {
          {
            type = "scala",
            request = "launch",
            name = "RunOrTest",
            metals = {
              runType = "runOrTestFile",
            },
          },
          {
            type = "scala",
            request = "launch",
            name = "Test Target",
            metals = {
              runType = "testTarget",
            },
          },
        }
      end
    },
  },
  ft = { "scala", "sbt" },
  opts = function()
    local metals_config = require("metals").bare_config()

    -- Example of settings
    metals_config.settings = {
      showImplicitArguments = true,
      excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
      testUserInterface = "Test Explorer"
    }

    -- *READ THIS*
    -- I *highly* recommend setting statusBarProvider to either "off" or "on"
    --
    -- "off" will enable LSP progress notifications by Metals and you'll need
    -- to ensure you have a plugin like fidget.nvim installed to handle them.
    --
    -- "on" will enable the custom Metals status extension and you *have* to have
    -- a have settings to capture this in your statusline or else you'll not see
    -- any messages from metals. There is more info in the help docs about this
    metals_config.init_options.statusBarProvider = "off"

    -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
    metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

    metals_config.on_attach = function(client, bufnr)
      require("metals").setup_dap()
      -- LSP mappings
      map("n", "gi", vim.lsp.buf.implementation, { desc = '[G]o to [I]mplementation' })
      map("n", "gr", vim.lsp.buf.references, { desc = '[G]o to [R]eferences' })
      map("n", "gds", vim.lsp.buf.document_symbol, { desc = '[G]o to [D]ocument [S]ymbols' })
      map("n", "gws", vim.lsp.buf.workspace_symbol, { desc = '[G]o to [W]orkspace [S]ymbols' })
      map("n", "<leader>cl", vim.lsp.codelens.run, { desc = '[C]ode [L]ens run' })
      -- map("n", "<leader>sh", vim.lsp.buf.signature_help)
      map("n", "<leader>f", vim.lsp.buf.format, { desc = '[F]ormat buffer' })
      map("n", "<leader>ws", function()
        require("metals").hover_worksheet()
      end, { desc = '[W]ork[s]heet hover' })
      -- all workspace diagnostics
      map("n", "<leader>aa", vim.diagnostic.setqflist, { desc = '[A]ll [A]ll diagnostics to quickfix' })
      -- all workspace errors
      map("n", "<leader>ae", function()
        vim.diagnostic.setqflist({ severity = "E" })
      end, { desc = '[A]ll [E]rrors to quickfix' })
      -- all workspace warnings
      map("n", "<leader>aw", function()
        vim.diagnostic.setqflist({ severity = "W" })
      end, { desc = '[A]ll [W]arnings to quickfix' })
      -- buffer diagnostics only
      map("n", "<leader>d", vim.diagnostic.setloclist, { desc = '[D]iagnostics (buffer) to loclist' })
      map("n", "[c", function()
        vim.diagnostic.goto_prev({ wrap = false })
      end, { desc = 'Go to previous [c] diagnostic' })
      map("n", "]c", function()
        vim.diagnostic.goto_next({ wrap = false })
      end, { desc = 'Go to next [c] diagnostic' })
      -- Example mappings for usage with nvim-dap. If you don't use that, you can
      -- skip these
      map("n", "<leader>rr", function()
        require("dap").run(require("dap").configurations.scala[1])
      end, { desc = 'Dap [R]un cu[r]rent file' })

      map("n", "<leader>dc", function()
        require("dap").continue()
      end, { desc = '[D]ap start/[C]ontinue session' })
      map("n", "<leader>dr", function()
        require("dap").repl.toggle()
      end, { desc = '[D]ap [R]epl toggle' })
      map("n", "<leader>dk", function()
        require("dap.ui.widgets").hover()
      end, { desc = '[D]ap hover ([k])' })
      map("n", "<leader>dt", function()
        require("dap").toggle_breakpoint()
      end, { desc = '[D]ap [T]oggle breakpoint' })
      map("n", "<leader>dso", function()
        require("dap").step_over()
      end, { desc = '[D]ap [S]tep [O]ver' })
      map("n", "<leader>dsi", function()
        require("dap").step_into()
      end, { desc = '[D]ap [S]tep [I]nto' })
      map("n", "<leader>dl", function()
        require("dap").run_last()
      end, { desc = '[D]ap run [L]ast' })

      map("n", "<leader>dst", function()
        vim.cmd("MetalsSelectTestSuite")
      end, { desc = '[D]ap [S]elect [T]est suite' })

      map("n", "<leader>dsc", function()
        vim.cmd("MetalsSelectTestCase")
      end, { desc = '[D]ap [S]elect test [C]ase' })

      map("v", "<leader>de", function()
        require("dap.ui.widgets").hover()
      end, { desc = '[D]ap [E]valuate selection' })

      map("n", "<leader>dss", function()
        local widgets = require("dap.ui.widgets")
        widgets.sidebar(widgets.scopes).open()
      end, { desc = '[D]ap [S]copes [s]idebar' })


      -- auto compile
      vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
        group = vim.api.nvim_create_augroup("MetalsAutoCompile" .. bufnr, { clear = true }),
        buffer = bufnr,
        callback = function()
          if vim.bo[bufnr].modified then
            vim.cmd("silent! write")
            require("metals").compile_cascade()
          end
        end,
      })
    end

    return metals_config
  end,
  config = function(self, metals_config)
    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = self.ft,
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end
}
