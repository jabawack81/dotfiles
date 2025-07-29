return {
  "michaelrommel/nvim-silicon",
  lazy = true,
  cmd = "Silicon",
  config = function()
    require("silicon").setup({
      font = "FiraCode Nerd Font",
      theme = "Monokai Extended Origin",
      output = function(filename)
        return "./"
          .. vim.fn.fnamemodify(
            vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
            ":t"
          )
          .. "-"
          .. os.date("%Y-%m-%d-%H-%M-%S")
          .. ".png"
      end,
    })
  end,
}
