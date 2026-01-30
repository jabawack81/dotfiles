-- ============================================================================
-- LSP Server Configuration
-- ============================================================================
-- This file configures Language Server Protocol (LSP) servers for different
-- programming languages. Each server provides IDE features like:
--   - Go to definition / Find references
--   - Autocomplete
--   - Diagnostics (errors, warnings)
--   - Hover documentation
--   - Code actions (refactoring, quick fixes)
--
-- HOW IT WORKS:
--   LazyVim + Mason automatically install and start LSP servers.
--   This file customizes server settings and adds servers not in defaults.
--
-- ADDING A NEW SERVER:
--   1. Add it to the `servers` table below with any custom settings
--   2. Mason will auto-install it (or install manually with :Mason)
--   3. Open a file of that type - LSP should attach automatically
--
-- DEBUGGING:
--   :LspInfo     - See which LSP servers are attached to current buffer
--   :LspLog      - View LSP server logs
--   :LspRestart  - Restart the LSP server
--   :Mason       - Manage installed servers
--
-- REQUIREMENTS:
--   - mason.nvim (auto-installs servers)
--   - mason-lspconfig.nvim (bridges Mason with lspconfig)
-- ============================================================================

-- Import lspconfig for utility functions (root_pattern, etc.)
local lspconfig = require("lspconfig")

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- ======================================================================
      -- Global LSP Settings
      -- ======================================================================

      -- Show a notification when formatting is triggered
      -- Useful for debugging when format-on-save isn't working
      format_notify = true,

      -- Inlay hints show inline type annotations (like TypeScript's inferred types)
      -- Disabled because they can be visually noisy - enable if you want them
      -- Toggle with: vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      inlay_hints = { enabled = false },

      -- ======================================================================
      -- Server Configurations
      -- ======================================================================
      -- Each key is a server name (must match lspconfig server name)
      -- Empty {} means use defaults, or provide custom settings
      servers = {
        -- ==================================================================
        -- GO (gopls)
        -- ==================================================================
        -- The official Go language server from Google
        -- Provides excellent Go support with many advanced features
        gopls = {
          settings = {
            gopls = {
              -- Use gofumpt for stricter formatting (superset of gofmt)
              gofumpt = true,

              -- Code lenses are clickable actions shown above functions/types
              -- They appear as grayed text like "run test | debug test"
              codelenses = {
                gc_details = false,        -- Show garbage collector details
                generate = true,           -- Show "go generate" lens
                regenerate_cgo = true,     -- Regenerate cgo definitions
                run_govulncheck = true,    -- Run vulnerability checker
                test = true,               -- Run tests
                tidy = true,               -- Run go mod tidy
                upgrade_dependency = true, -- Upgrade dependencies
                vendor = true,             -- Run go mod vendor
              },

              -- Inlay hints (inline type annotations)
              -- These show types, parameter names, etc. inline in your code
              hints = {
                assignVariableTypes = true,     -- x := foo() shows type of x
                compositeLiteralFields = true,  -- Show field names in structs
                compositeLiteralTypes = true,   -- Show types in composite literals
                constantValues = true,          -- Show values of constants
                functionTypeParameters = true,  -- Show type params in generics
                parameterNames = true,          -- Show parameter names in calls
                rangeVariableTypes = true,      -- Show types in range loops
              },

              -- Static analysis checks
              analyses = {
                nilness = true,      -- Check for redundant nil checks
                unusedparams = true, -- Warn about unused parameters
                unusedwrite = true,  -- Warn about unused writes to variables
                useany = true,       -- Suggest using 'any' instead of 'interface{}'
              },

              -- Use placeholders in completions (shows parameter names)
              usePlaceholders = true,

              -- Auto-import packages when completing symbols
              completeUnimported = true,

              -- Enable staticcheck linter integration
              staticcheck = true,

              -- Directories to exclude from analysis (improves performance)
              directoryFilters = {
                "-.git",
                "-.vscode",
                "-.idea",
                "-.vscode-test",
                "-node_modules",
              },

              -- Enable semantic syntax highlighting
              semanticTokens = true,
            },
          },
        },

        -- ==================================================================
        -- BASH (bashls)
        -- ==================================================================
        -- Language server for shell scripts
        -- Also handles zsh files (added to filetypes)
        bashls = {
          filetypes = { "sh", "zsh" }, -- Handle both bash and zsh
        },

        -- ==================================================================
        -- RUBY (ruby_lsp)
        -- ==================================================================
        -- Ruby LSP from Shopify - modern Ruby language server
        -- Provides: completion, diagnostics, formatting, go-to-definition
        --
        -- IMPORTANT: Uses rbenv path - adjust if you use a different Ruby manager
        -- For rvm: cmd = { vim.fn.expand("~/.rvm/rubies/default/bin/ruby-lsp") }
        -- For asdf: cmd = { vim.fn.expand("~/.asdf/shims/ruby-lsp") }
        ruby_lsp = {
          init_options = {
            -- Auto-detect formatter (standard, rubocop, or syntax_tree)
            formatter = "auto",
          },
          -- Use rbenv's ruby-lsp binary
          -- This ensures it uses the correct Ruby version for your project
          cmd = { vim.fn.expand("~/.rbenv/shims/ruby-lsp") },
        },

        -- ==================================================================
        -- RUBOCOP (rubocop)
        -- ==================================================================
        -- Ruby linter and formatter as an LSP server
        -- Runs via bundler to use your project's Rubocop version
        -- See: https://docs.rubocop.org/rubocop/usage/lsp.html
        rubocop = {
          -- Run rubocop through bundler to use project-specific version
          cmd = { "bundle", "exec", "rubocop", "--lsp" },

          -- Find the project root by looking for these files
          root_dir = lspconfig.util.root_pattern("Gemfile", ".git", "."),
        },

        -- ==================================================================
        -- SQL (sqlls)
        -- ==================================================================
        -- SQL language server for .sql files
        -- Provides: completion, formatting, linting
        sqlls = {},

        -- ==================================================================
        -- TYPESCRIPT / JAVASCRIPT (ts_ls)
        -- ==================================================================
        -- TypeScript language server (handles both TS and JS)
        -- Provides: completion, diagnostics, refactoring, go-to-definition
        ts_ls = {},

        -- ==================================================================
        -- YAML (yamlls)
        -- ==================================================================
        -- YAML language server
        -- Provides: completion, validation, hover (supports JSON schemas)
        yamlls = {},

        -- ==================================================================
        -- COMMENTED OUT SERVERS (enable if needed)
        -- ==================================================================
        -- Uncomment any of these if you work with these languages

        -- denols = {},      -- Deno (alternative to Node.js)
        -- diagnosticls = {}, -- Generic diagnostic server
        -- dockerls = {},    -- Dockerfile
        -- helm_ls = {},     -- Helm charts (Kubernetes)
        -- jsonls = {},      -- JSON (LazyVim may already configure this)
        -- jsonnet_ls = {},  -- Jsonnet
        -- lua_ls = {},      -- Lua (LazyVim already configures this)
        -- marksman = {},    -- Markdown
        -- terraformls = {}, -- Terraform

        -- regols - Rego (Open Policy Agent) - NOT managed by Mason
        -- Install manually: brew install kitagry/tap/regols
        -- See: https://github.com/kitagry/regols
        -- regols = {},
      },

      -- ======================================================================
      -- Server Setup Hooks
      -- ======================================================================
      -- Custom setup functions that run when a server attaches
      -- Use for workarounds or advanced configuration
      setup = {
        -- Workaround for gopls semantic tokens issue
        -- https://github.com/golang/go/issues/54531#issuecomment-1464982242
        gopls = function(_, opts)
          -- Use Snacks.util.lsp.on (LazyVim.lsp.on_attach is deprecated)
          -- Signature: Snacks.util.lsp.on(filter, callback) where filter = { name = "server_name" }
          Snacks.util.lsp.on({ name = "gopls" }, function(buf, client)
            -- If gopls doesn't advertise semantic tokens support, enable it manually
            if not client.server_capabilities.semanticTokensProvider then
              local semantic = client.config.capabilities.textDocument.semanticTokens
              client.server_capabilities.semanticTokensProvider = {
                full = true,
                legend = {
                  tokenTypes = semantic.tokenTypes,
                  tokenModifiers = semantic.tokenModifiers,
                },
                range = true,
              }
            end
          end)
        end,
      },
    },
  },
}
