-- Next.js file navigation for monorepos
-- Auto-detects Next.js apps and adapts categories to each app's structure
return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      {
        "<leader>fN",
        function()
          local cwd = vim.fn.getcwd()
          local next_apps = {}

          local function dir_exists(rel_path)
            return vim.fn.isdirectory(cwd .. "/" .. rel_path) == 1
          end

          -- Check if cwd itself is a Next.js app
          if #vim.fn.glob(cwd .. "/next.config.*", false, true) > 0 then
            table.insert(next_apps, { name = vim.fn.fnamemodify(cwd, ":t"), prefix = "" })
          end

          -- Check subdirectories
          local entries = vim.fn.readdir(cwd)
          for _, entry in ipairs(entries) do
            local path = cwd .. "/" .. entry
            if vim.fn.isdirectory(path) == 1 then
              if #vim.fn.glob(path .. "/next.config.*", false, true) > 0 then
                table.insert(next_apps, { name = entry, prefix = entry .. "/" })
              end
            end
          end

          if #next_apps == 0 then
            vim.notify("No Next.js apps found in current directory", vim.log.levels.WARN)
            return
          end

          local function browse_app(app)
            local p = app.prefix
            local categories = {}

            local function add(name, cmd)
              table.insert(categories, { name = name, cmd = cmd })
            end

            -- Pages — App Router (src/app/) or Pages Router (src/pages/)
            if dir_exists(p .. "src/app") then
              add("Pages (App Router)", "fd -t f -g 'page.{tsx,ts,jsx,js}' " .. p .. "src/app")
              add("Layouts", "fd -t f -g 'layout.{tsx,ts,jsx,js}' " .. p .. "src/app")
            end
            if dir_exists(p .. "src/pages") then
              add("Pages (Router)", "fd -t f -e tsx -e ts -e jsx -e js . " .. p .. "src/pages")
            end

            -- Common src/ directories — only shown if they exist
            local src_dirs = {
              { "Components", "components" },
              { "Hooks", "hooks" },
              { "Lib", "lib" },
              { "Helpers", "helpers" },
              { "Types", "types" },
              { "Styles", "styles" },
              { "Constants", "constants" },
              { "Data Access", "dataAccess" },
              { "Contexts", "contexts" },
              { "Actions", "actions" },
              { "Providers", "providers" },
              { "Utils", "utils" },
              { "Collections", "collections" },
              { "Config (app)", "config" },
            }

            for _, entry in ipairs(src_dirs) do
              local dir = p .. "src/" .. entry[2]
              if dir_exists(dir) then
                add(entry[1], "fd -t f -e tsx -e ts -e jsx -e js . " .. dir)
              end
            end

            -- API routes (App Router)
            if dir_exists(p .. "src/app/api") then
              add("API Routes", "fd -t f -g 'route.{ts,js}' " .. p .. "src/app/api")
            end

            -- Tests — __tests__/ at app root
            if dir_exists(p .. "__tests__") then
              add("Tests", "fd -t f -e ts -e tsx -e js -e jsx . " .. p .. "__tests__")
            end

            -- Config files at app root
            local search_root = p == "" and "." or p:sub(1, -2)
            add("Config", "fd -t f -d 1 -g '{next,tailwind,postcss,tsconfig,biome,jest,vitest,knip}*' " .. search_root)

            local names = {}
            for _, cat in ipairs(categories) do
              table.insert(names, cat.name)
            end

            require("fzf-lua").fzf_exec(names, {
              prompt = app.name .. " > ",
              actions = {
                ["default"] = function(selected)
                  if selected and selected[1] then
                    for _, cat in ipairs(categories) do
                      if cat.name == selected[1] then
                        require("fzf-lua").files({
                          prompt = app.name .. "/" .. cat.name .. " > ",
                          cmd = cat.cmd,
                        })
                        break
                      end
                    end
                  end
                end,
              },
            })
          end

          if #next_apps == 1 then
            browse_app(next_apps[1])
            return
          end

          local app_names = {}
          for _, app in ipairs(next_apps) do
            table.insert(app_names, app.name)
          end

          require("fzf-lua").fzf_exec(app_names, {
            prompt = "Next.js App > ",
            actions = {
              ["default"] = function(selected)
                if selected and selected[1] then
                  for _, app in ipairs(next_apps) do
                    if app.name == selected[1] then
                      browse_app(app)
                      break
                    end
                  end
                end
              end,
            },
          })
        end,
        desc = "Next.js files",
      },
    },
  },
}
