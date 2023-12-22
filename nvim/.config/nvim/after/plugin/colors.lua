local colorSchemes = { dark = "kanagawa-dragon", light = "tokyonight-day"}

function SetColorScheme(color)
	color = color or "dark"

	vim.cmd.colorscheme(colorSchemes[color])
	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end


Light = function() SetColorScheme("light") end
Dark = SetColorScheme

Dark()


-- local colorSchemes = { dark = "catppuccin-mocha", light = "catppuccin-latte"}

-- require("catppuccin").setup({
--   transparent_background = true,
-- 	-- dim_inactive = {
-- 	-- 	enabled = true,
-- 	-- 	shade = "dark",
-- 	-- 	percentage = 0.15,
-- 	-- },
--   integrations = {
--         treesitter = true,
--   }
-- })

-- function SetColorScheme(color)
-- 	color = color or "dark"
-- 	vim.cmd.colorscheme(colorSchemes[color])
-- end


-- Light = function() SetColorScheme("light") end
-- Dark = SetColorScheme

-- Dark()

