vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
	callback = function()
    vim.bo.tw = 80
	end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
	callback = function()
    vim.bo.tw = 80
	end,
})

