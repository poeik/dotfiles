vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false

-- for undo tree
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.incsearch = true

vim.opt.termguicolors = true

-- min 8 lines at the end
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.colorcolumn = "80"

-- change default split behaviour
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.spell = true
vim.opt.spelllang = "en,de_ch" -- https://ftp.nluug.nl/vim/runtime/spell/
-- no spell check for checkhealth
vim.api.nvim_create_autocmd("FileType", {
  pattern = "checkhealth",
  callback = function()
    vim.opt_local.spell = false
  end,
})


-- vertical git diff split by default
vim.opt.diffopt:append("vertical")

vim.diagnostic.config({
  virtual_text = true, -- inline errors
})
-- needed for tree-sitter-purescript and language server
vim.filetype.add({ extension = { purs = 'purescript' }})


-- disable default nvim file explorer 
vim.g.loaded_netrw       = 1
vim.g.loaded_netrwPlugin = 1


-- used for obsidian-nvim
vim.opt.conceallevel = 1

