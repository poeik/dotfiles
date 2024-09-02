return {
  'tpope/vim-commentary',
  config = function()
    -- define how to comment frege files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "frege",
      callback = function()
        vim.opt_local.commentstring = "-- %s"
      end,
    })
  end
}
