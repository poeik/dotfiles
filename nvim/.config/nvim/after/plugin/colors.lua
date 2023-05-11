-- run :lua SetColorScheme() to recolor neovim after a PackerSync

function SetColorScheme(color)
	color = color or "dragon"

  --  catppuccin catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
	-- vim.cmd.colorscheme("catppuccin-" .. color)
	vim.cmd.colorscheme("kanagawa-" .. color)
end


White = function() SetColorScheme("lotus") end
Dark = SetColorScheme

Dark()
