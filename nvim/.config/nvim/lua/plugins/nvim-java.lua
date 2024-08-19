return {
  -- lazy = true,
  'nvim-java/nvim-java',
  priority = 1000,
  dependencies = {
    'nvim-java/lua-async-await',
    'nvim-java/nvim-java-refactor',
    'nvim-java/nvim-java-core',
    'nvim-java/nvim-java-test',
    'nvim-java/nvim-java-dap',
    'MunifTanjim/nui.nvim',
    'neovim/nvim-lspconfig',
    'mfussenegger/nvim-dap',
    {
      'williamboman/mason.nvim',
      opts = {
        registries = {
          'github:nvim-java/mason-registry',
          'github:mason-org/mason-registry',
        },
      },
    }
  },
  config = function()
    require('java').setup()
    require('lspconfig').jdtls.setup({})
  end,
  keys = {
    {'<F5>',       function() require('dap').continue() end, desc = ""},
    {'<F10>',      function() require('dap').step_over() end, desc = ""},
    {'<F11>',      function() require('dap').step_into() end, desc = ""},
    {'<F12>',      function() require('dap').step_out() end, desc = ""},
    {'<Leader>b',  function() require('dap').toggle_breakpoint() end, desc = ""},
    {'<Leader>B',  function() require('dap').set_breakpoint() end, desc = ""},
    {'<Leader>lp', function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, desc = ""},
    {'<Leader>dr', function() require('dap').repl.open() end, desc = ""},
    {'<Leader>dl', function() require('dap').run_last() end, desc = ""},
    {
     '<Leader>df',
      function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.frames)
      end,
      desc = ""
    },
    {
     '<Leader>ds',
      function()
        local widgets = require('dap.ui.widgets')
        widgets.centered_float(widgets.scopes)
      end,
      desc = ""
    },
    {
     '<Leader>dh',
      function() require('dap.ui.widgets').hover() end,
      desc = "",
      mode = {'n', 'v'}
    },
    {
     '<Leader>dp',
      function() require('dap.ui.widgets').preview() end,
      desc = "",
      mode = {'n', 'v'}
    },
  }
}
