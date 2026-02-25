return {
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<leader>fe",
      function()
        require("neo-tree.command").execute({
          toggle = true,
          dir = LazyVim.root(),
        })
      end,
      desc = "Explorer NeoTree (Root Dir)",
    },
    {
      "<leader>fE",
      function()
        require("neo-tree.command").execute({
          toggle = true,
          dir = vim.uv.cwd(),
        })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
    {
      "<leader>e",
      "<leader>fe",
      desc = "Explorer NeoTree (Root Dir)",
      remap = true,
    },
    {
      "<leader>E",
      "<leader>fE",
      desc = "Explorer NeoTree (cwd)",
      remap = true,
    },
    {
      "<leader>ge",
      function()
        require("neo-tree.command").execute({
          source = "git_status",
          toggle = true,
        })
      end,
      desc = "Git Explorer",
    },
    {
      "<leader>gE",
      function()
        local test_patterns = {
          "__tests__/", "__snapshots__/", "%.test%.", "%.spec%.",
          "_spec%.rb$", "/spec/", "/coverage/", "/junit/",
        }

        local function is_test(path)
          for _, pat in ipairs(test_patterns) do
            if path:match(pat) then
              return true
            end
          end
          return false
        end

        -- Recursively remove test nodes from the nui tree, then prune empty dirs
        local function filter_tree(tree, parent_id)
          local to_remove = {}
          local children = tree:get_nodes(parent_id)
          for _, node in ipairs(children) do
            local id = node:get_id()
            if is_test(id) then
              table.insert(to_remove, id)
            else
              local grandchildren = tree:get_nodes(id)
              if #grandchildren > 0 then
                filter_tree(tree, id)
                if #tree:get_nodes(id) == 0 then
                  table.insert(to_remove, id)
                end
              end
            end
          end
          for _, id in ipairs(to_remove) do
            tree:remove_node(id)
          end
        end

        -- Open git status tree, then filter after render
        require("neo-tree.command").execute({ source = "git_status", action = "show" })

        vim.defer_fn(function()
          local manager = require("neo-tree.sources.manager")
          local state = manager.get_state("git_status")
          if state and state.tree then
            filter_tree(state.tree)
            require("neo-tree.ui.renderer").redraw(state)
          end
        end, 300)
      end,
      desc = "Git Explorer (no tests)",
    },
    {
      "<leader>be",
      function()
        require("neo-tree.command").execute({
          source = "buffers",
          toggle = true,
        })
      end,
      desc = "Buffer Explorer",
    },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    -- FIX: use `autocmd` for lazy-loading neo-tree instead of directly requiring it,
    -- because `cwd` is not set up properly.
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup(
        "Neotree_start_directory",
        { clear = true }
      ),
      desc = "Start Neo-tree with directory",
      once = true,
      callback = function()
        if package.loaded["neo-tree"] then
          return
        else
          local stats = vim.uv.fs_stat(vim.fn.argv(0))
          if stats and stats.type == "directory" then
            require("neo-tree")
          end
        end
      end,
    })
  end,
  opts = {
    sources = { "filesystem", "buffers", "git_status" },
    open_files_do_not_replace_types = {
      "terminal",
      "Trouble",
      "trouble",
      "qf",
      "Outline",
    },
    git_status_async_options = {
      batch_size = 1000,
      batch_delay = 10,
      max_lines = 10000,
    },
    filesystem = {
      bind_to_cwd = true,
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = false,
      async_directory_scan = "always",
    },
    window = {
      mappings = {
        ["l"] = "open",
        ["h"] = "close_node",
        ["<space>"] = "none",
        ["Y"] = {
          function(state)
            local node = state.tree:get_node()
            local path = node:get_id()
            vim.fn.setreg("+", path, "c")
          end,
          desc = "Copy Path to Clipboard",
        },
        ["O"] = {
          function(state)
            require("lazy.util").open(
              state.tree:get_node().path,
              { system = true }
            )
          end,
          desc = "Open with System Application",
        },
        ["P"] = { "toggle_preview", config = { use_float = false } },
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
      git_status = {
        symbols = {
          unstaged = "󰄱",
          staged = "󰱒",
        },
      },
    },
  },
  config = function(_, opts)
    local function on_move(data)
      Snacks.rename.on_rename_file(data.source, data.destination)
    end

    local events = require("neo-tree.events")
    opts.event_handlers = opts.event_handlers or {}
    vim.list_extend(opts.event_handlers, {
      { event = events.FILE_MOVED, handler = on_move },
      { event = events.FILE_RENAMED, handler = on_move },
    })
    require("neo-tree").setup(opts)
    vim.api.nvim_create_autocmd("TermClose", {
      pattern = "*lazygit",
      callback = function()
        if package.loaded["neo-tree.sources.git_status"] then
          require("neo-tree.sources.git_status").refresh()
        end
      end,
    })
  end,
}
