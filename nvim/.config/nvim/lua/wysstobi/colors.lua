local colorSchemes = {
  dark  = { theme = "catppuccin-mocha", guibg = '#212121' },
  light = { theme = "catppuccin-latte", guibg = '#BCC0CC' }
}

local ALACRITTY_CONFIG = "~/.config/alacritty/alacritty.toml"

function SetColorScheme(color)
  local colorScheme = colorSchemes[color]

  require("catppuccin").setup({
    transparent_background = true,
    integrations = {
      treesitter = true,
    },
    custom_highlights = {
      ColorColumn = { bg = colorScheme.guibg }
    }
  })

	vim.cmd.colorscheme(colorScheme["theme"])
end

local function replaceInConfigFile(searchFor, replaceWith, file)
  local cmd = string.format("sed -i '' 's/%s/%s/' %s", searchFor, replaceWith, file)
  os.execute(cmd)
end

Light = function()
  SetColorScheme("light")
  replaceInConfigFile("alacritty-dark", "alacritty-light", ALACRITTY_CONFIG)
end

Dark = function()
  SetColorScheme("dark")
  replaceInConfigFile("alacritty-light", "alacritty-dark", ALACRITTY_CONFIG)
end

Dark()
