-- Fix for LazyVim treesitter build field error
-- This ensures nvim-treesitter has a proper build configuration

return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = function(_, opts)
      -- Ensure opts exists
      opts = opts or {}
      
      -- Ensure ensure_installed exists and has basic parsers
      opts.ensure_installed = opts.ensure_installed or {}
      local ensure_installed = opts.ensure_installed
      
      -- Add essential parsers if not already present
      local essential = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      }
      
      for _, parser in ipairs(essential) do
        if not vim.tbl_contains(ensure_installed, parser) then
          table.insert(ensure_installed, parser)
        end
      end
      
      return opts
    end,
  },
}