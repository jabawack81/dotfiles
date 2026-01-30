-- ============================================================================
-- Copilot Configuration
-- ============================================================================
-- GitHub Copilot integration for Neovim using copilot.lua
-- This provides AI-powered code suggestions as you type.
--
-- REQUIREMENTS:
--   - Node.js version > 18.x
--   - GitHub Copilot subscription
--   - Run :Copilot auth to authenticate on first use
--
-- HOW IT WORKS:
--   Copilot runs as a background language server that analyzes your code
--   context and provides inline suggestions (ghost text) as you type.
--   You can accept, dismiss, or cycle through multiple suggestions.
--
-- TWO MODES OF OPERATION:
--   1. Inline Suggestions - Ghost text appears as you type (auto_trigger)
--   2. Panel Mode - Opens a split showing multiple completions to choose from
-- ============================================================================

return {
  -- ==========================================================================
  -- Which-key Integration
  -- ==========================================================================
  -- Registers the <leader>cp prefix with which-key so all Copilot commands
  -- are grouped together and discoverable via the which-key popup menu.
  -- Press <leader> to see available groups, then 'cp' for Copilot commands.
  {
    "folke/which-key.nvim",
    optional = true, -- Only applies if which-key is installed
    opts = {
      spec = {
        { "<leader>cp", group = "copilot" }, -- Creates the 'copilot' group
      },
    },
  },

  -- ==========================================================================
  -- Copilot Plugin Configuration
  -- ==========================================================================
  {
    "zbirenbaum/copilot.lua",

    -- ========================================================================
    -- Keybindings
    -- ========================================================================
    -- These keybindings are registered with lazy.nvim and will show up in
    -- which-key. The 'mode' field specifies when the keybinding is active:
    --   "i" = insert mode only
    --   "n" = normal mode (default if not specified)
    keys = {
      -- INSERT MODE KEYBINDINGS (while typing)
      -- Accept the current ghost text suggestion with Ctrl+j
      -- Using Ctrl+j instead of Tab avoids conflicts with completion plugins
      { "<C-j>", desc = "Accept Copilot suggestion", mode = "i" },

      -- Open the suggestions panel with Alt+Enter to see multiple options
      { "<M-CR>", desc = "Open Copilot panel", mode = "i" },

      -- NORMAL MODE KEYBINDINGS (via leader key)
      -- Toggle whether suggestions appear automatically as you type
      -- Useful when Copilot is distracting or you want manual control
      {
        "<leader>cpt",
        function()
          require("copilot.suggestion").toggle_auto_trigger()
        end,
        desc = "Toggle auto-trigger",
      },

      -- Open the panel showing multiple completion options
      -- Useful when the inline suggestion isn't what you want
      {
        "<leader>cpp",
        function()
          require("copilot.panel").open()
        end,
        desc = "Open panel",
      },

      -- Cycle to the next suggestion (Copilot generates multiple options)
      {
        "<leader>cps",
        function()
          require("copilot.suggestion").next()
        end,
        desc = "Next suggestion",
      },

      -- Cycle to the previous suggestion
      {
        "<leader>cpS",
        function()
          require("copilot.suggestion").prev()
        end,
        desc = "Previous suggestion",
      },

      -- Dismiss/hide the current suggestion without accepting it
      {
        "<leader>cpd",
        function()
          require("copilot.suggestion").dismiss()
        end,
        desc = "Dismiss suggestion",
      },
    },

    -- ========================================================================
    -- Plugin Options
    -- ========================================================================
    opts = {
      -- ----------------------------------------------------------------------
      -- Inline Suggestions Configuration
      -- ----------------------------------------------------------------------
      -- These settings control the ghost text that appears as you type
      suggestion = {
        enabled = true, -- Enable inline suggestions feature

        -- Automatically show suggestions as you type
        -- Set to false if you prefer manual triggering only
        auto_trigger = true,

        -- Milliseconds to wait after typing before requesting suggestions
        -- Higher values = less CPU/network usage but slower suggestions
        -- Lower values = faster but more resource intensive
        debounce = 75,

        -- Keymap to accept the inline suggestion
        -- Using Ctrl+j to avoid conflicts with Tab (used by completion menus)
        keymap = { accept = "<C-j>" },
      },

      -- ----------------------------------------------------------------------
      -- Panel Configuration
      -- ----------------------------------------------------------------------
      -- The panel shows multiple completion options in a split window
      -- Useful when you want to see and compare different suggestions
      panel = {
        enabled = true, -- Enable the panel feature

        -- Don't automatically refresh suggestions in the panel
        -- Set to true if you want live updates as context changes
        auto_refresh = false,

        -- Keybindings when the panel is open
        keymap = {
          jump_prev = "[[", -- Jump to previous suggestion in panel
          jump_next = "]]", -- Jump to next suggestion in panel
          accept = "<C-y>", -- Accept the highlighted suggestion
          refresh = "gr", -- Manually refresh suggestions
          open = "<M-CR>", -- Alt+Enter to open panel from insert mode
        },

        -- Panel window layout
        layout = {
          position = "bottom", -- Where to open: "bottom", "top", "left", "right"
          ratio = 0.4, -- Panel takes 40% of the screen height/width
        },
      },

      -- ----------------------------------------------------------------------
      -- Filetype Configuration
      -- ----------------------------------------------------------------------
      -- Control which file types Copilot is enabled/disabled for
      -- true = enabled, false = disabled
      filetypes = {
        markdown = true, -- Enable for markdown files
        help = true, -- Enable for help files
        gitcommit = false, -- Disable for git commit messages (write your own!)
        gitrebase = false, -- Disable for git rebase
        ["."] = false, -- Disable for dotfiles (hidden files)
      },

      -- ----------------------------------------------------------------------
      -- Node.js Configuration
      -- ----------------------------------------------------------------------
      -- Copilot requires Node.js to run. This specifies the command to use.
      -- Must be Node.js version > 18.x
      copilot_node_command = "node",

      -- ----------------------------------------------------------------------
      -- Server Configuration
      -- ----------------------------------------------------------------------
      -- Advanced settings for the Copilot language server
      server_opts_overrides = {
        trace = "verbose", -- Enable verbose logging for debugging

        settings = {
          advanced = {
            -- Number of completions to generate for the panel view
            listCount = 10,

            -- Number of completions to generate for inline suggestions
            -- Higher = more options to cycle through with next/prev
            inlineSuggestCount = 3,
          },
        },
      },
    },
  },
}
