-- Rails file navigation for monorepos with engines
return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      {
        "<leader>fr",
        function()
          -- Auto-detect Rails app directory by looking for subdirs with app/models
          local function find_rails_root()
            local cwd = vim.fn.getcwd()
            -- Check if cwd itself is a Rails app
            if vim.fn.isdirectory(cwd .. "/app/models") == 1 then
              return ""
            end
            -- Check subdirectories for Rails app structure
            local entries = vim.fn.readdir(cwd)
            for _, entry in ipairs(entries) do
              local path = cwd .. "/" .. entry
              if vim.fn.isdirectory(path .. "/app/models") == 1 then
                return entry
              end
            end
            return nil
          end

          local rails_root = find_rails_root()
          if not rails_root then
            vim.notify("No Rails app found in current directory", vim.log.levels.WARN)
            return
          end

          local prefix = rails_root ~= "" and (rails_root .. "/") or ""

          local categories = {
            { name = "Models", pattern = prefix .. "app/models/**/*.rb" },
            { name = "Controllers", pattern = prefix .. "app/controllers/**/*.rb" },
            { name = "Views", pattern = prefix .. "app/views/**/*" },
            { name = "Helpers", pattern = prefix .. "app/helpers/**/*.rb" },
            { name = "Services", pattern = prefix .. "app/services/**/*.rb" },
            { name = "Jobs", pattern = prefix .. "app/jobs/**/*.rb" },
            { name = "Mailers", pattern = prefix .. "app/mailers/**/*.rb" },
            { name = "Specs", pattern = prefix .. "spec/**/*_spec.rb" },
            { name = "Engine Models", pattern = "engines/*/app/models/**/*.rb" },
            { name = "Engine Controllers", pattern = "engines/*/app/controllers/**/*.rb" },
            { name = "Engine Views", pattern = "engines/*/app/views/**/*" },
            { name = "Engine Specs", pattern = "engines/*/spec/**/*_spec.rb" },
          }

          local names = {}
          for _, cat in ipairs(categories) do
            table.insert(names, cat.name)
          end

          require("fzf-lua").fzf_exec(names, {
            prompt = "Rails > ",
            actions = {
              ["default"] = function(selected)
                if selected and selected[1] then
                  for _, cat in ipairs(categories) do
                    if cat.name == selected[1] then
                      require("fzf-lua").files({
                        prompt = cat.name .. " > ",
                        cmd = "rg --files --follow -g '" .. cat.pattern .. "'",
                      })
                      break
                    end
                  end
                end
              end,
            },
          })
        end,
        desc = "Rails files",
      },
    },
  },
}
