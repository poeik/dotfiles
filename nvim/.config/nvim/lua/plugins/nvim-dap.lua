return {
  'mfussenegger/nvim-dap',
  config = function ()
      vim.keymap.set("n", "<leader>ds", function()
        require("dap").run_last()
      end, { desc = '[d]ap [s]art a new session' })
  end
}
