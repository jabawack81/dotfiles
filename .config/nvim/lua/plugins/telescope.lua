return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- add a keymap to browse plugin files
      -- stylua: ignore
      {
        "<leader>fp",
        function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end,
        desc = "Find Plugin File",
      },
    },
    -- change some options
    opts = {
      defaults = {
        layout_strategy = "horizontal",
        -- layout_config = {
        --
        --   width = function(_, cols, _)
        --     if cols > 200 then
        --       return 170
        --     else
        --       return math.floor(cols * 0.9)
        --     end
        --   end,
        --   height = function(_, _, lines)
        --     if lines > 50 then
        --       return math.floor(lines * 0.5)
        --     else
        --       return math.floor(lines * 0.9)
        --     end
        --   end,

        -- preview_cutoff = 120,
        --
        -- horizontal = {
        --   prompt_position = "top",
        --   preview_width = 0.2,
        --   results_width = 0.8,
        -- },
        -- vertical = {
        --   prompt_position = "top",
        --   preview_width = 0.9,
        --   results_width = 0.1,
        --   --   mirror = false,
        -- },
        -- width = 0.9,
        -- height = 0.9,
        -- },
        --  layout_config = {
        --    width = 0.87,
        --    height = 0.80,
        --    prompt_position = "bottom",
        --  },
        --sorting_strategy = "ascending",
        --winblend = 0,
      },
      -- pickers = {
      --   find_files = {
      --     theme = "dropdown",
      --   },
      -- },
    },
  },
}
