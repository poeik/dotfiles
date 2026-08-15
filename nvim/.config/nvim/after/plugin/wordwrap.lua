vim.api.nvim_create_autocmd("FileType", {
  pattern = "typst",
	callback = function()
    vim.bo.tw = 80
	end,
})

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "markdown",
-- 	callback = function()
--     vim.bo.tw = 80
-- 	end,
-- })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "text" },
  callback = function(args)
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.breakindent = true
    vim.opt_local.textwidth = 0

    -- treat j k as if it were normal lines
    local opts = { buffer = args.buf, expr = true, silent = true }
    vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", opts)
    vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", opts)
  end,
})
