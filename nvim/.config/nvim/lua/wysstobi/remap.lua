vim.g.mapleader = " "
vim.keymap.set("i", "<C-c>", "<Esc>")

-- open explorer
--vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- enable line reordering with capital "j" & "k" in visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- cursor stays in the middle with half page jumps
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- search terms stay in the middle
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- replace without adding old text to clipboard
vim.keymap.set("x", "<leader>p", [["_dP]])

-- copy to system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- replace word your on in whole file
--vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- switch tabs
vim.keymap.set('n', '±', '1gt', opts)
vim.keymap.set('n', '“', '2gt', opts)
vim.keymap.set('n', '#', '3gt', opts)
vim.keymap.set('n', 'Ç', '4gt', opts)
vim.keymap.set('n', '[', '5gt', opts)
vim.keymap.set('n', ']', '6gt', opts)
vim.keymap.set('n', '|', '7gt', opts)
vim.keymap.set('n', '{', '8gt', opts)
vim.keymap.set('n', '}', '9gt', opts)
vim.keymap.set('n', '≠', '0gt', opts)
