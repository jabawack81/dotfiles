-- Claude Code integration for Neovim
-- Uses the official WebSocket protocol (same as VS Code extension)
-- Claude sees your open buffers, selections, and diagnostics
return {
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      terminal = {
        split_side = "right",
        split_width_percentage = 0.35,
      },
    },
    keys = {
      { "<leader>c",  nil,                                desc = "Claude Code" },
      { "<leader>cc", "<cmd>ClaudeCode<cr>",              desc = "Toggle Claude" },
      { "<leader>cf", "<cmd>ClaudeCodeFocus<cr>",         desc = "Focus Claude" },
      { "<leader>cr", "<cmd>ClaudeCode --resume<cr>",     desc = "Resume conversation" },
      { "<leader>ck", "<cmd>ClaudeCode --continue<cr>",   desc = "Continue conversation" },
      { "<leader>cs", "<cmd>ClaudeCodeSend<cr>",          mode = "v", desc = "Send selection to Claude" },
      { "<leader>cb", "<cmd>ClaudeCodeAdd %<cr>",         desc = "Add buffer to context" },
      { "<leader>cy", "<cmd>ClaudeCodeDiffAccept<cr>",    desc = "Accept diff" },
      { "<leader>cn", "<cmd>ClaudeCodeDiffDeny<cr>",      desc = "Deny diff" },
      {
        "<leader>ct",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file from tree",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
      },
    },
  },

  -- Register the Claude Code which-key group
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>c", group = "Claude Code" },
      },
    },
  },
}
