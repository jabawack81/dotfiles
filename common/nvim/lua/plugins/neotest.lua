-- Test runner integration via neotest
-- Adapters: RSpec (Rails), Jest (Next.js apps), Vitest
return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "olimorris/neotest-rspec",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    -- stylua: ignore
    keys = {
      { "<leader>tt", function() require("neotest").run.run() end, desc = "Run Nearest" },
      { "<leader>tT", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Run File" },
      { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Run All" },
      { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Run Last" },
      { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Toggle Summary" },
      { "<leader>to", function() require("neotest").output.open({ enter_on_open = true }) end, desc = "Show Output" },
      { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Toggle Output Panel" },
      { "<leader>tS", function() require("neotest").run.stop() end, desc = "Stop" },
      { "<leader>tw", function() require("neotest").watch.toggle(vim.fn.expand("%")) end, desc = "Toggle Watch" },
    },
    opts = {
      adapters = {},
    },
    config = function(_, opts)
      opts.adapters = {
        require("neotest-rspec")({
          rspec_cmd = function()
            return { "bundle", "exec", "rspec" }
          end,
        }),
        require("neotest-jest")({
          jestCommand = "npx jest",
          cwd = function(path)
            -- Resolve to nearest package.json for monorepo support
            local root = require("lspconfig.util").root_pattern("package.json")(path)
            return root or vim.uv.cwd()
          end,
        }),
        require("neotest-vitest"),
      }
      require("neotest").setup(opts)
    end,
  },
}
