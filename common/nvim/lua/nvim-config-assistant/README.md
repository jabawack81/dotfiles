# Neovim Config Assistant

A Neovim plugin that provides an AI-powered assistant to answer questions about your Neovim configuration.

## Features

- Opens a floating prompt window to ask questions
- Analyzes your current Neovim configuration
- **Tracks and analyzes errors** - automatically captures LSP diagnostics, vim errors, and notifications
- Queries an LLM (OpenAI or Anthropic) to provide context-aware answers
- Displays results in a scrollable floating window

## Installation

The plugin is already set up in your config. To use it:

1. Set your API key as an environment variable:
   ```bash
   export OPENAI_API_KEY="your-api-key-here"
   # or for Anthropic:
   export ANTHROPIC_API_KEY="your-api-key-here"
   ```

2. Restart Neovim or source the plugin file

## Usage

- Press `<leader>qa` to open the assistant prompt
- Press `<leader>qe` to open the assistant with current error context (includes error under cursor and recent errors)
- Type your question (e.g., "How do I fix this error?" or "How do I jump between errors?")
- Press Enter to submit
- The assistant will analyze your config and provide an answer
- Press `q` or `<Esc>` to close the result window

## Commands

- `:ConfigAssistant` - Opens the assistant prompt
- `:ConfigAssistantError` - Opens the assistant with error context

## Configuration

Edit the plugin configuration in `~/.config/nvim/lua/plugins/nvim-config-assistant.lua` to:
- Change LLM provider (OpenAI or Anthropic)
- Use different models
- Customize keybindings
- Adjust window appearance

## Example Questions

- "How do I jump between errors in TypeScript files?"
- "What are my git-related keybindings?"
- "How do I format code?"
- "What LSP servers are configured?"
- "How do I search for files?"
- "How do I fix this TypeScript error?" (when using `<leader>qe` with cursor on error)
- "What does this error mean?" (when errors are captured)