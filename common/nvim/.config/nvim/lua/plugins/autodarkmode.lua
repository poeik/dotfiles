
return {
  "f-person/auto-dark-mode.nvim",
  opts = {
   set_dark_mode = function()
        Dark()
    end,
    set_light_mode = function()
        Light()
    end,
    update_interval = 1500,
    fallback = "dark"}
}
