-- Rails file navigation for monorepos with engines
return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      {
        "<leader>fr",
        function()
          local cwd = vim.fn.getcwd()

          -- Auto-detect Rails app directory
          local function find_rails_root()
            if vim.fn.isdirectory(cwd .. "/app/models") == 1 then
              return ""
            end
            local entries = vim.fn.readdir(cwd)
            for _, entry in ipairs(entries) do
              if vim.fn.isdirectory(cwd .. "/" .. entry .. "/app/models") == 1 then
                return entry
              end
            end
            return nil
          end

          -- Check if a directory exists relative to cwd
          local function dir_exists(rel_path)
            return vim.fn.isdirectory(cwd .. "/" .. rel_path) == 1
          end

          -- Check if a directory looks like a Rails engine (has app/ and any .gemspec)
          local function is_engine(rel_path)
            if not dir_exists(rel_path .. "/app") then
              return false
            end
            return #vim.fn.glob(cwd .. "/" .. rel_path .. "/*.gemspec", false, true) > 0
          end

          -- Find all engine directories, scanning multiple locations
          local function find_engines(rails_prefix)
            local engines = {}
            local seen = {}

            local function scan_dir(base)
              local abs = cwd .. "/" .. base
              if vim.fn.isdirectory(abs) ~= 1 then
                return
              end
              local entries = vim.fn.readdir(abs)
              for _, entry in ipairs(entries) do
                local rel = base == "" and entry or (base .. "/" .. entry)
                -- Resolve symlinks to avoid duplicates
                local real = vim.fn.resolve(cwd .. "/" .. rel)
                if not seen[real] and is_engine(rel) then
                  seen[real] = true
                  table.insert(engines, rel)
                end
              end
            end

            -- Scan: top-level, engines/, {rails_root}/engines/
            scan_dir("")
            scan_dir("engines")
            if rails_prefix ~= "" then
              scan_dir(rails_prefix .. "engines")
            end

            return engines
          end

          local rails_root = find_rails_root()
          if not rails_root then
            vim.notify("No Rails app found in current directory", vim.log.levels.WARN)
            return
          end

          local p = rails_root ~= "" and (rails_root .. "/") or ""

          -- Build categories, only including dirs that exist
          local categories = {}
          local function add(name, cmd)
            table.insert(categories, { name = name, cmd = cmd })
          end

          -- Common Rails app/ subdirectories — only shown if they exist
          local app_dirs = {
            "models", "controllers", "services", "operations", "jobs",
            "decorators", "presenters", "queries", "serializers",
            "validators", "mailers", "helpers",
          }

          for _, dir_name in ipairs(app_dirs) do
            local dir = p .. "app/" .. dir_name
            if dir_exists(dir) then
              -- Capitalize for display: "models" -> "Models"
              add(dir_name:sub(1, 1):upper() .. dir_name:sub(2), "fd -t f -e rb . " .. dir)
            end
          end

          if dir_exists(p .. "app/views") then
            add("Views", "fd -t f . " .. p .. "app/views")
          end
          if dir_exists(p .. "app/api") then
            add("API", "fd -t f -e rb . " .. p .. "app/api")
          end
          if dir_exists(p .. "spec") then
            add("Specs", "fd -t f -g '*_spec.rb' " .. p .. "spec")
          end

          -- Auto-detect engines (top-level, engines/, {rails_root}/engines/)
          local engines = find_engines(p)
          for _, engine in ipairs(engines) do
            -- Use just the directory name for the label (not the full path)
            local engine_name = vim.fn.fnamemodify(engine, ":t")
            local label = engine_name:gsub("[-_]", " "):gsub("(%a)([%w]*)", function(a, b)
              return a:upper() .. b
            end)

            for _, dir_name in ipairs(app_dirs) do
              local dir = engine .. "/app/" .. dir_name
              if dir_exists(dir) then
                add(label .. " " .. dir_name:sub(1, 1):upper() .. dir_name:sub(2),
                  "fd -t f -e rb . " .. dir)
              end
            end

            if dir_exists(engine .. "/app/views") then
              add(label .. " Views", "fd -t f . " .. engine .. "/app/views")
            end
            if dir_exists(engine .. "/spec") then
              add(label .. " Specs", "fd -t f -g '*_spec.rb' " .. engine .. "/spec")
            end
          end

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
                        cmd = cat.cmd,
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
