-- Enhanced navigation for Rails monorepos with engines
return {
  {
    "nvim-telescope/telescope.nvim",
    keys = {
      -- Fallback definition search when LSP fails
      {
        "gD",
        function()
          -- First try LSP declaration if available
          local clients = vim.lsp.get_active_clients({ bufnr = 0 })
          for _, client in pairs(clients) do
            if client.server_capabilities.declarationProvider then
              vim.lsp.buf.declaration()
              return
            end
          end
          
          -- Fallback to custom search
          local word = vim.fn.expand("<cword>")
          
          -- For class/module names (PascalCase), search for definition
          if word:match("^[A-Z]") then
            -- Search for class/module definitions
            require("telescope.builtin").grep_string({
              search = "(class|module)\\s+" .. word .. "\\b",
              use_regex = true,
              prompt_title = "Find Definition: " .. word,
              additional_args = function()
                return { "--type", "ruby" }
              end,
            })
          else
            -- For methods and other identifiers
            local patterns = {
              -- Ruby method definitions
              "def\\s+(self\\.)?" .. word .. "\\b",
              -- Ruby constant assignments
              "^\\s*" .. word .. "\\s*=",
              -- Rails model scopes
              "scope\\s+:" .. word .. "\\b",
              -- Rails associations
              "(has_many|has_one|belongs_to|has_and_belongs_to_many)\\s+:" .. word .. "\\b",
            }
            
            require("telescope.builtin").grep_string({
              search = table.concat(patterns, "|"),
              use_regex = true,
              prompt_title = "Find Definition: " .. word,
              additional_args = function()
                return { "--type", "ruby" }
              end,
            })
          end
        end,
        desc = "Search definition (fallback)",
      },
      -- Search for Rails-specific patterns
      {
        "<leader>fr",
        function()
          local telescope = require("telescope.builtin")
          local actions = require("telescope.actions")
          local action_state = require("telescope.actions.state")
          
          -- Rails-specific search options
          local rails_searches = {
            { name = "Models", pattern = "app/models/**/*.rb" },
            { name = "Controllers", pattern = "app/controllers/**/*.rb" },
            { name = "Views", pattern = "app/views/**/*" },
            { name = "Helpers", pattern = "app/helpers/**/*.rb" },
            { name = "Services", pattern = "app/services/**/*.rb" },
            { name = "Jobs", pattern = "app/jobs/**/*.rb" },
            { name = "Mailers", pattern = "app/mailers/**/*.rb" },
            { name = "Engine Models", pattern = "engines/*/app/models/**/*.rb" },
            { name = "Engine Controllers", pattern = "engines/*/app/controllers/**/*.rb" },
            { name = "Engine Views", pattern = "engines/*/app/views/**/*" },
            { name = "Specs", pattern = "spec/**/*_spec.rb" },
            { name = "Engine Specs", pattern = "engines/*/spec/**/*_spec.rb" },
          }
          
          -- Create picker for Rails file types
          require("telescope.pickers").new({}, {
            prompt_title = "Rails Files",
            finder = require("telescope.finders").new_table({
              results = rails_searches,
              entry_maker = function(entry)
                return {
                  value = entry.pattern,
                  display = entry.name,
                  ordinal = entry.name,
                }
              end,
            }),
            sorter = require("telescope.config").values.generic_sorter({}),
            attach_mappings = function(prompt_bufnr, map)
              actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection then
                  telescope.find_files({
                    search_dirs = { "." },
                    prompt_title = selection.display,
                    find_command = { "fd", "--type", "f", "--glob", selection.value },
                  })
                end
              end)
              return true
            end,
          }):find()
        end,
        desc = "Rails files",
      },
      -- Search in engines
      {
        "<leader>fe",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Engine Files",
            search_dirs = { "engines", "components", "gems", "vendor/engines" },
          })
        end,
        desc = "Engine files",
      },
      -- Go to Ruby class/module definition
      {
        "<leader>gd",
        function()
          local word = vim.fn.expand("<cword>")
          -- Use live_grep for better performance with large codebases
          require("telescope.builtin").live_grep({
            default_text = "(class|module) " .. word .. "\\b",
            prompt_title = "Go to Class: " .. word,
            additional_args = function()
              return { "--type", "ruby", "--regexp" }
            end,
          })
        end,
        desc = "Go to class definition",
      },
      -- Alternative: Find file by class name
      {
        "<leader>gf",
        function()
          local word = vim.fn.expand("<cword>")
          -- Convert CamelCase to snake_case for file search
          local filename = word:gsub("(%u)(%u%l)", "%1_%2"):gsub("(%l)(%u)", "%1_%2"):lower()
          
          require("telescope.builtin").find_files({
            prompt_title = "Find File: " .. filename,
            search_file = filename .. ".rb",
            find_command = { "fd", "--type", "f", "--glob", "**/" .. filename .. ".rb" },
          })
        end,
        desc = "Find file by class name",
      },
    },
  },
}