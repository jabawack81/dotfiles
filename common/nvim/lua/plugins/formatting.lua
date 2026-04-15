-- Biome formatter for JS/TS projects
-- Biome auto-detects config by walking up to the nearest biome.json
return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "biome" },
        javascriptreact = { "biome" },
        typescript = { "biome" },
        typescriptreact = { "biome" },
        json = { "biome" },
        jsonc = { "biome" },
      },
      -- Override rubocop to run via bundler so it picks up project-specific gems
      -- (e.g. rubocop-rails, rubocop-rspec, or custom rubocop-* cops from Gemfile)
      formatters = {
        rubocop = {
          command = "bundle",
          args = function(_, ctx)
            return {
              "exec",
              "rubocop",
              "--autocorrect",
              "--force-exclusion",
              "--stdin",
              ctx.filename,
              "--stderr",
              "--format",
              "files",
            }
          end,
        },
      },
    },
  },
}
