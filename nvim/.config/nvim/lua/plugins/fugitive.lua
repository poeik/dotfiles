return {
  'tpope/vim-fugitive',
  config = function()
    vim.keymap.set("n", "<leader>tg", vim.cmd.Git)
    vim.keymap.set("n", "<leader>ga", function()
      local buffers = vim.api.nvim_list_bufs()
      local fugitive_buffers = vim.tbl_filter(function(buffer)
        return vim.api.nvim_buf_is_loaded(buffer) and vim.bo[buffer].filetype == 'fugitiveblame'
      end, buffers)

      if #fugitive_buffers > 0 then
        vim.api.nvim_buf_delete(fugitive_buffers[1], { force = true })
      else
        vim.cmd('G blame')
      end
    end)
  end

}
