-- lua/plugins/theme.lua
-- Try to load omarchy theme, fall back to nord if not available

local omarchy_theme = vim.fn.expand("~/.config/omarchy/current/theme/neovim.lua")

if vim.fn.filereadable(omarchy_theme) == 1 then
  -- Omarchy system - load dynamic theme
  return dofile(omarchy_theme)
else
  -- Non-omarchy system - use nord as fallback
  return {
    {
      "shaunsingh/nord.nvim",
      lazy = false,
      priority = 1000,
      config = function()
        vim.g.nord_disable_background = true
      end,
    },
    {
      "LazyVim/LazyVim",
      opts = {
        colorscheme = "nord",
      },
    },
  }
end
