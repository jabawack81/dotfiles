-- Plugin for createpr CLI tool integration
return {
  {
    "nvim-lua/plenary.nvim",
    config = function()
      -- Create PR command - runs createpr from project root
      vim.api.nvim_create_user_command("CreatePR", function(opts)
        -- Get the git root directory
        local handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
        if handle then
          local git_root = handle:read("*a"):gsub("%s+", "")
          handle:close()
          
          if git_root and git_root ~= "" then
            -- Build the command
            local cmd = "cd " .. vim.fn.shellescape(git_root) .. " && createpr"
            
            -- Add any arguments passed to the command
            if opts.args and opts.args ~= "" then
              cmd = cmd .. " " .. opts.args
            end
            
            -- Execute the command
            vim.fn.system(cmd)
            vim.notify("Opening PR creation page...", vim.log.levels.INFO)
          else
            vim.notify("Not in a git repository", vim.log.levels.ERROR)
          end
        else
          vim.notify("Failed to find git root", vim.log.levels.ERROR)
        end
      end, { 
        nargs = "*",
        desc = "Open GitHub PR creation page using createpr tool",
      })
    end,
  },
}