-- ============================================================================
-- Keybindings Help
-- ============================================================================
-- Opens the KEYBINDINGS.md cheatsheet.
--
-- USAGE:
--   <leader>hk   - Open keybindings cheatsheet (floating window)
--   <leader>hK   - Open keybindings cheatsheet (full buffer)
--   :Keybindings - Open keybindings cheatsheet (command)
--
-- INSIDE THE VIEW:
--   q            - Close (in floating window)
--   gx           - Follow link under cursor (native vim)
--   /            - Search
--   Uses render-markdown.nvim for nice formatting if installed
-- ============================================================================

local keybindings_file = vim.fn.stdpath("config") .. "/KEYBINDINGS.md"

-- Open in a floating window
local function open_floating()
  if vim.fn.filereadable(keybindings_file) == 0 then
    vim.notify("KEYBINDINGS.md not found", vim.log.levels.ERROR)
    return
  end

  -- Use Snacks.win if available (LazyVim includes this)
  local has_snacks, snacks = pcall(require, "snacks")
  if has_snacks and snacks.win then
    snacks.win({
      file = keybindings_file,
      width = 0.85,
      height = 0.85,
      wo = {
        wrap = false,
        spell = false,
        signcolumn = "no",
        statuscolumn = "",
      },
      keys = {
        q = "close",
        ["<Esc>"] = "close",
      },
    })
  else
    -- Fallback: open in a split
    vim.cmd("vsplit " .. keybindings_file)
    vim.bo.readonly = true
    vim.bo.modifiable = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true })
  end
end

-- Open in a full buffer
local function open_buffer()
  if vim.fn.filereadable(keybindings_file) == 0 then
    vim.notify("KEYBINDINGS.md not found", vim.log.levels.ERROR)
    return
  end
  vim.cmd("edit " .. keybindings_file)
end

return {
  -- Register with which-key
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>h", group = "help" },
      },
    },
  },

  -- Keybindings
  {
    "folke/snacks.nvim",
    optional = true,
    keys = {
      { "<leader>hk", open_floating, desc = "Keybindings (float)" },
      { "<leader>hK", open_buffer, desc = "Keybindings (buffer)" },
    },
    init = function()
      vim.api.nvim_create_user_command("Keybindings", open_floating, {
        desc = "Open Keybindings Cheatsheet",
      })
    end,
  },
}
