return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  branch = "main",
  config = function()
    local parsers = { "kotlin", "java", "javascript", "typescript", "lua", "python", "haskell" }

    require('nvim-treesitter').install(parsers)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = parsers,
      callback = function() vim.treesitter.start() end,
    })

    -- use Haskell parser for Frege files
    vim.treesitter.language.register('haskell', 'frege')
    -- set file type for all *.fr to "Frege" 
    vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
      pattern = "*.fr",
      command = "set filetype=frege",
    })
 end
}
