return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter.configs').setup {
      modules ={},
      ignore_install = {},
      -- A list of parser names, or "all"
      ensure_installed = { "kotlin", "java", "javascript", "typescript", "lua" }, -- langugages are syntax highlighted

      -- Install parsers synchronously (only applied to `ensure_installed`)
      sync_install = false,

      -- Automatically install missing parsers when entering buffer
      -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
      auto_install = true,

      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<c-backspace>',
        }
      },

      highlight = {
        -- `false` will disable the whole extension
        enable = true,
        disable = { "latex" },
        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
      },
      -- filetype_to_parsername = {
      --   fr = "haskell",  -- Verknüpft den Dateityp 'frege' mit dem Haskell-Parser
      -- },
    }
    -- use haskell parser for frege files
    vim.treesitter.language.register('haskell', 'frege')
    -- set filetype for all *.fr to "frege" 
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = "*.fr",
      command = "set filetype=frege",
    })
 end
}
