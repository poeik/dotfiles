-- run :lua SetColorScheme() to recolor neovim after a PackerSync

function SetColorScheme(color)
	color = color or "macchiato"

  --  catppuccin catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
	vim.cmd.colorscheme("catppuccin-" .. color)
end


White = function() SetColorScheme("latte") end
Dark = SetColorScheme

Dark()
