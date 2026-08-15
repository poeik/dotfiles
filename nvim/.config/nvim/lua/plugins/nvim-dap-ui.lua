return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup()
    vim.keymap.set({ "n", "v" }, "<leader>de", function()
      require("dapui").eval()
    end, { desc = '[D]ap [E]valuate expression' })

    -- auto open/close the UI with the debug session lifecycle
    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open()
    end

    vim.keymap.set("n", "<leader>dut", function()
      require("dapui").toggle()
    end, { desc = '[D]ap toggle ui ([x])' })
    vim.keymap.set("n", "<leader>dx", function()
      require("dap").terminate()
      require("dapui").close()
    end, { desc = '[D]ap close ui ([x])' })

  end,
}
