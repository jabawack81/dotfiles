-- ============================================================================
-- Copilot Chat Configuration
-- ============================================================================
-- This file configures CopilotChat.nvim, an AI chat interface that lets you
-- have conversations with GitHub Copilot about your code.
--
-- WHAT IS COPILOT CHAT?
--   Unlike inline Copilot suggestions (ghost text as you type), Copilot Chat
--   is a conversational interface where you can:
--   - Ask questions about code
--   - Request explanations, reviews, or refactoring
--   - Generate tests, documentation, or commit messages
--   - Get help with errors and debugging
--
-- HOW IT WORKS:
--   1. Select code (visual mode) or place cursor in a file
--   2. Use a keybinding like <leader>ae to explain the code
--   3. A chat window opens with Copilot's response
--   4. You can continue the conversation or ask follow-up questions
--
-- REQUIREMENTS:
--   - GitHub Copilot subscription (same as inline Copilot)
--   - Authenticated via :Copilot auth
--
-- PLUGIN: CopilotC-Nvim/CopilotChat.nvim
--   GitHub: https://github.com/CopilotC-Nvim/CopilotChat.nvim
-- ============================================================================

-- Development flag - set to true only if you're developing the plugin locally
-- For normal use, this should always be false
local IS_DEV = false

-- ============================================================================
-- Custom Prompts
-- ============================================================================
-- These prompts are sent to Copilot when you use the corresponding command.
-- You can customize these or add your own prompts here.
-- Each prompt becomes a command: :CopilotChat<PromptName>
-- Example: prompts.Explain -> :CopilotChatExplain
local prompts = {
  -- CODE-RELATED PROMPTS
  -- These work best when you have code selected or cursor in a code file

  -- Explain what the selected code does, step by step
  Explain = "Please explain how the following code works.",

  -- Review code for bugs, performance issues, and best practices
  Review = "Please review the following code and provide suggestions for improvement.",

  -- Generate unit tests for the selected code
  Tests = "Please explain how the selected code works, then generate unit tests for it.",

  -- Improve code readability and structure without changing behavior
  Refactor = "Please refactor the following code to improve its clarity and readability.",

  -- Fix broken or buggy code
  FixCode = "Please fix the following code to make it work as intended.",

  -- Explain an error message and suggest how to fix it
  FixError = "Please explain the error in the following text and provide a solution.",

  -- Suggest more descriptive names for variables and functions
  BetterNamings = "Please provide better names for the following variables and functions.",

  -- Generate documentation comments (docstrings, JSDoc, etc.)
  Documentation = "Please provide documentation for the following code.",

  -- Generate Swagger/OpenAPI documentation for an API
  SwaggerApiDocs = "Please provide documentation for the following API using Swagger.",

  -- Generate JSDoc comments with Swagger annotations
  SwaggerJsDocs = "Please write JSDoc for the following API using Swagger.",

  -- TEXT-RELATED PROMPTS
  -- These work with any text, not just code

  -- Condense text to key points
  Summarize = "Please summarize the following text.",

  -- Fix typos and grammar mistakes
  Spelling = "Please correct any grammar and spelling errors in the following text.",

  -- Improve writing style and clarity
  Wording = "Please improve the grammar and wording of the following text.",

  -- Make text shorter while preserving meaning
  Concise = "Please rewrite the following text to make it more concise.",
}

return {
  -- ==========================================================================
  -- Which-key Integration
  -- ==========================================================================
  -- Register AI-related keybinding groups with which-key for discoverability
  {
    "folke/which-key.nvim",
    optional = true,
    opts = {
      spec = {
        { "<leader>a", group = "ai" },        -- All AI commands under <leader>a
        { "<leader>gm", group = "Copilot Chat" }, -- Alternative group
      },
    },
  },

  -- ==========================================================================
  -- Markdown Rendering (Optional)
  -- ==========================================================================
  -- Enables pretty markdown rendering in the chat window
  -- Makes responses easier to read with proper formatting
  {
    "MeanderingProgrammer/render-markdown.nvim",
    optional = true,
    opts = {
      file_types = { "markdown", "copilot-chat" },
    },
    ft = { "markdown", "copilot-chat" },
  },

  -- ==========================================================================
  -- Main Copilot Chat Plugin
  -- ==========================================================================
  {
    -- Use local development version if IS_DEV is true, otherwise use GitHub
    dir = IS_DEV and "~/Projects/research/CopilotChat.nvim" or nil,
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",

    -- Uncomment to pin to a specific version (prevents breaking changes)
    -- version = "v3.3.0",

    dependencies = {
      { "nvim-telescope/telescope.nvim" }, -- Fuzzy finder for prompt selection
      { "nvim-lua/plenary.nvim" },         -- Lua utilities library
    },

    -- ========================================================================
    -- Plugin Options
    -- ========================================================================
    opts = {
      -- Headers shown in the chat window to distinguish speakers
      question_header = "## User ",    -- Your messages
      answer_header = "## Copilot ",   -- Copilot's responses
      error_header = "## Error ",      -- Error messages

      -- Use our custom prompts defined above
      prompts = prompts,

      -- Uncomment to use a different model (if available)
      -- model = "claude-3.7-sonnet",

      -- ----------------------------------------------------------------------
      -- Chat Window Keybindings
      -- ----------------------------------------------------------------------
      -- These keybindings are active when you're inside the chat window
      mappings = {
        -- Tab completion for @mentions and /commands
        complete = {
          detail = "Use @<Tab> or /<Tab> for options.",
          insert = "<Tab>",
        },

        -- Close the chat window
        close = {
          normal = "q",       -- Press q in normal mode
          insert = "<C-c>",   -- Ctrl+c in insert mode
        },

        -- Clear the chat history and start fresh
        reset = {
          normal = "<C-x>",
          insert = "<C-x>",
        },

        -- Send your message to Copilot
        submit_prompt = {
          normal = "<CR>",      -- Enter in normal mode
          insert = "<C-CR>",    -- Ctrl+Enter in insert mode
        },

        -- Accept a code diff suggestion from Copilot
        accept_diff = {
          normal = "<C-y>",
          insert = "<C-y>",
        },

        -- Show help for chat window keybindings
        show_help = {
          normal = "g?",
        },
      },
    },

    -- ========================================================================
    -- Plugin Setup Function
    -- ========================================================================
    config = function(_, opts)
      local chat = require("CopilotChat")
      chat.setup(opts)

      local select = require("CopilotChat.select")

      -- --------------------------------------------------------------------
      -- Custom Commands
      -- --------------------------------------------------------------------

      -- :CopilotChatVisual - Chat about visually selected code
      -- Usage: Select code in visual mode, then run :CopilotChatVisual <question>
      vim.api.nvim_create_user_command("CopilotChatVisual", function(args)
        chat.ask(args.args, { selection = select.visual })
      end, { nargs = "*", range = true })

      -- :CopilotChatInline - Show response in a floating window near cursor
      -- Useful for quick questions without opening a full chat window
      vim.api.nvim_create_user_command("CopilotChatInline", function(args)
        chat.ask(args.args, {
          selection = select.visual,
          window = {
            layout = "float",
            relative = "cursor",
            width = 1,
            height = 0.4,
            row = 1,
          },
        })
      end, { nargs = "*", range = true })

      -- :CopilotChatBuffer - Chat about the entire current buffer
      -- Usage: :CopilotChatBuffer <question about the whole file>
      vim.api.nvim_create_user_command("CopilotChatBuffer", function(args)
        chat.ask(args.args, { selection = select.buffer })
      end, { nargs = "*", range = true })

      -- --------------------------------------------------------------------
      -- Auto-command for Chat Buffers
      -- --------------------------------------------------------------------
      -- When entering a Copilot chat buffer, enable line numbers and
      -- set filetype to markdown for better syntax highlighting
      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-*",
        callback = function()
          vim.opt_local.relativenumber = true
          vim.opt_local.number = true

          -- Treat copilot-chat buffers as markdown for syntax highlighting
          local ft = vim.bo.filetype
          if ft == "copilot-chat" then
            vim.bo.filetype = "markdown"
          end
        end,
      })
    end,

    -- Load plugin after startup to avoid slowing down Neovim
    event = "VeryLazy",

    -- ========================================================================
    -- Keybindings
    -- ========================================================================
    -- All keybindings are under <leader>a (AI group)
    keys = {
      -- --------------------------------------------------------------------
      -- Prompt Selection
      -- --------------------------------------------------------------------

      -- Show all available prompts in a Telescope picker (normal mode)
      -- Includes context from open buffers
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt({
            context = { "buffers" },
          })
        end,
        desc = "CopilotChat - Prompt actions",
      },

      -- Show prompts for selected text (visual mode)
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        mode = "x",
        desc = "CopilotChat - Prompt actions",
      },

      -- --------------------------------------------------------------------
      -- Code Commands (work on selected code or current buffer)
      -- --------------------------------------------------------------------

      -- Explain what the code does
      { "<leader>ae", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },

      -- Generate unit tests for the code
      { "<leader>at", "<cmd>CopilotChatTests<cr>", desc = "CopilotChat - Generate tests" },

      -- Review code for issues and improvements
      { "<leader>ar", "<cmd>CopilotChatReview<cr>", desc = "CopilotChat - Review code" },

      -- Refactor code for better readability
      { "<leader>aR", "<cmd>CopilotChatRefactor<cr>", desc = "CopilotChat - Refactor code" },

      -- Suggest better variable/function names
      { "<leader>an", "<cmd>CopilotChatBetterNamings<cr>", desc = "CopilotChat - Better Naming" },

      -- --------------------------------------------------------------------
      -- Visual Mode Commands (require selected text)
      -- --------------------------------------------------------------------

      -- Open chat about selected code in a vertical split
      {
        "<leader>av",
        ":CopilotChatVisual",
        mode = "x",
        desc = "CopilotChat - Open in vertical split",
      },

      -- Show inline floating chat near the cursor
      {
        "<leader>ax",
        ":CopilotChatInline",
        mode = "x",
        desc = "CopilotChat - Inline chat",
      },

      -- --------------------------------------------------------------------
      -- Free-form Questions
      -- --------------------------------------------------------------------

      -- Ask a custom question (opens input prompt)
      {
        "<leader>ai",
        function()
          local input = vim.fn.input("Ask Copilot: ")
          if input ~= "" then
            vim.cmd("CopilotChat " .. input)
          end
        end,
        desc = "CopilotChat - Ask input",
      },

      -- Quick chat about the current buffer
      {
        "<leader>aq",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            vim.cmd("CopilotChatBuffer " .. input)
          end
        end,
        desc = "CopilotChat - Quick chat",
      },

      -- --------------------------------------------------------------------
      -- Git Integration
      -- --------------------------------------------------------------------

      -- Generate a commit message based on staged changes
      {
        "<leader>am",
        "<cmd>CopilotChatCommit<cr>",
        desc = "CopilotChat - Generate commit message for all changes",
      },

      -- --------------------------------------------------------------------
      -- Diagnostics
      -- --------------------------------------------------------------------

      -- Fix the current diagnostic error
      { "<leader>af", "<cmd>CopilotChatFixError<cr>", desc = "CopilotChat - Fix Diagnostic" },

      -- --------------------------------------------------------------------
      -- Chat Management
      -- --------------------------------------------------------------------

      -- Clear chat history and start fresh
      { "<leader>al", "<cmd>CopilotChatReset<cr>", desc = "CopilotChat - Clear buffer and chat history" },

      -- Toggle the chat window open/closed
      { "<leader>av", "<cmd>CopilotChatToggle<cr>", desc = "CopilotChat - Toggle" },

      -- --------------------------------------------------------------------
      -- Model and Agent Selection
      -- --------------------------------------------------------------------

      -- Choose which AI model to use
      { "<leader>a?", "<cmd>CopilotChatModels<cr>", desc = "CopilotChat - Select Models" },

      -- Choose which AI agent to use
      { "<leader>aa", "<cmd>CopilotChatAgents<cr>", desc = "CopilotChat - Select Agents" },
    },
  },
}
