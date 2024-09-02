return {
  "nvim-tree/nvim-web-devicons",
  lazy = false,
  config = function ()
    require('nvim-web-devicons').setup {
      override_by_extension = {
        ["fr"] = {
          icon = "󰘧",
          color = "#cc3e44",
          name = "Frege"
        },
        ["spec.fr"] = {
          icon = "󰙨",
          color = "#20c2e3",
          name = "FregeSpec"
        }
      };
    }
    end
  }
