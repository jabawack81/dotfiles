-- fzf-lua: file:line:col support for the files picker
-- Type "file.rb:316" in <leader>ff → fzf matches "file.rb", opens at line 316
return {
  {
    "ibhagwan/fzf-lua",
    keys = {
      {
        "<leader>ff",
        function()
          local fzf = require("fzf-lua")
          local raw_query_file = vim.fn.tempname()
          fzf.files({
            fzf_opts = {
              -- Save raw query (with :line:col) to temp file, then strip for matching
              ["--bind"] = string.format(
                [[change:execute-silent(printf '%%s' {q} > %s)+transform-query(echo {q} | sed 's/:[0-9]*\(:[0-9]*\)\{0,1\}$//' )]],
                raw_query_file
              ),
            },
            actions = {
              ["default"] = function(selected, opts)
                if not selected or #selected == 0 then return end
                require("fzf-lua.actions").file_edit(selected, opts)
                -- Read the raw query to check for :line:col
                local f = io.open(raw_query_file, "r")
                if f then
                  local raw = f:read("*a")
                  f:close()
                  os.remove(raw_query_file)
                  local _, lnum_s, col_s = raw:match("^(.+):(%d+):?(%d*)$")
                  if lnum_s then
                    local lnum = math.min(tonumber(lnum_s), vim.api.nvim_buf_line_count(0))
                    local col = math.max(0, (tonumber(col_s) or 1) - 1)
                    pcall(vim.api.nvim_win_set_cursor, 0, { lnum, col })
                    vim.cmd("normal! zz")
                  end
                end
              end,
            },
          })
        end,
        desc = "Find Files (Root Dir)",
      },
    },
  },
}
