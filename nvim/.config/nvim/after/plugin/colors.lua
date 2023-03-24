-- run :lua ColorMyPencils() to recolor neovim after a PackerSync

function ColorMyPencils(color)
  --  catppuccin catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
	color = color or "catppuccin-mocha"
	vim.cmd.colorscheme(color)
end


ColorMyPencils()

