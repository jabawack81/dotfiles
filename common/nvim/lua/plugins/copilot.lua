return {
  "zbirenbaum/copilot.lua",
  opts = {
    suggestion = {
      enabled = true,
      auto_trigger = true,
      debounce = 75,
      keymap = { accept = "<C-j>" },
    },
    panel = {
      enabled = true,
      auto_refresh = false,
      keymap = {
        jump_prev = "[[",
        jump_next = "]]",
        accept = "<C-y>",
        refresh = "gr",
        open = "<M-CR>",
      },
      layout = {
        position = "bottom", -- | top | left | right
        ratio = 0.4,
      },
    },
    filetypes = {
      markdown = true,
      help = true,
      gitcommit = false,
      gitrebase = false,
      ["."] = false,
    },
    copilot_node_command = 'node', -- Node.js version must be > 18.x
    server_opts_overrides = {
      trace = "verbose",
      settings = {
        advanced = {
          listCount = 10, -- #completions for panel
          inlineSuggestCount = 3, -- #completions for getCompletions
        },
      },
    },
  },
}
