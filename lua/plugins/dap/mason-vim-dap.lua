return {
  {
    "mfussenegger/nvim-dap",

    dependencies = {
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },

    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "coreclr" },
      })

      local dap = require("dap")

      ----------------------------------------------------------------
      -- netcoredbg
      ----------------------------------------------------------------

      dap.adapters.coreclr = {
        type = "executable",
        command = "C:\\Users\\ppuczkowskyj\\Tools\\netcoredbg\\netcoredbg\\netcoredbg.exe",
        args = { "--interpreter=vscode" },
        options = {
          detached = false,
        },
      }

      ----------------------------------------------------------------
      -- Find and launch an ASP.NET Core project using launchSettings
      ----------------------------------------------------------------

      local function launch_dotnet_project()
        local root = vim.fn.getcwd()

        vim.notify("DAP root: " .. root)

        local projects = vim.fn.glob(root .. "/**/*.csproj", false, true)

        vim.notify("Found " .. #projects .. " project(s)")

        if #projects == 0 then
          vim.notify("No .csproj files found", vim.log.levels.ERROR)
          return
        end

        vim.ui.select(projects, {
          prompt = "Select .NET project:",
          format_item = function(path)
            return vim.fn.fnamemodify(path, ":.")
          end,
        }, function(project)
          if not project then
            return
          end

          local project_dir = vim.fn.fnamemodify(project, ":h")

          local project_name = vim.fn.fnamemodify(project, ":t:r")

          vim.notify("Project: " .. project)
          vim.notify("Project dir: " .. project_dir)
          vim.notify("Project name: " .. project_name)

          ------------------------------------------------------------
          -- launchSettings.json
          ------------------------------------------------------------

          local launch_settings = project_dir .. "/Properties/launchSettings.json"

          vim.notify("launchSettings: " .. launch_settings)

          if vim.fn.filereadable(launch_settings) == 0 then
            vim.notify("launchSettings.json not found", vim.log.levels.ERROR)
            return
          end

          local lines = vim.fn.readfile(launch_settings)
          local json = table.concat(lines, "\n")

          local ok, settings = pcall(vim.json.decode, json)

          if not ok then
            vim.notify("Failed to parse launchSettings.json: " .. tostring(settings), vim.log.levels.ERROR)
            return
          end

          ------------------------------------------------------------
          -- Select profile
          ------------------------------------------------------------

          local profile_names = {}

          for name, _ in pairs(settings.profiles or {}) do
            table.insert(profile_names, name)
          end

          table.sort(profile_names)

          vim.notify("Profiles: " .. table.concat(profile_names, ", "))

          vim.ui.select(profile_names, {
            prompt = "Select launch profile:",
          }, function(profile_name)
            if not profile_name then
              return
            end

            local profile = settings.profiles[profile_name]

            vim.notify("Selected profile: " .. profile_name)

            ----------------------------------------------------------
            -- Log the actual profile
            ----------------------------------------------------------

            vim.notify("applicationUrl: " .. tostring(profile.applicationUrl))

            vim.notify("commandName: " .. tostring(profile.commandName))

            ----------------------------------------------------------
            -- Environment
            ----------------------------------------------------------

            local env = {}

            if profile.environmentVariables then
              for key, value in pairs(profile.environmentVariables) do
                env[key] = value

                vim.notify("ENV " .. key .. "=" .. tostring(value))
              end
            end

            ----------------------------------------------------------
            -- Arguments
            ----------------------------------------------------------

            local args = {}

            if profile.applicationUrl then
              table.insert(args, "--urls")
              table.insert(args, profile.applicationUrl)
            end

            if profile.commandLineArgs then
              local profile_args = vim.split(profile.commandLineArgs, "%s+", { trimempty = true })

              vim.list_extend(args, profile_args)
            end

            vim.notify("DAP args: " .. vim.inspect(args))

            vim.notify("DAP env: " .. vim.inspect(env))

            ----------------------------------------------------------
            -- Find DLL
            ----------------------------------------------------------

            local dlls = vim.fn.glob(project_dir .. "/bin/Debug/*/" .. project_name .. ".dll", false, true)

            vim.notify("Found " .. #dlls .. " matching DLL(s)")

            for _, candidate in ipairs(dlls) do
              vim.notify("DLL candidate: " .. candidate)
            end

            if #dlls == 0 then
              vim.notify("Could not find compiled DLL", vim.log.levels.ERROR)
              return
            end

            local dll = nil

            for _, candidate in ipairs(dlls) do
              if candidate:find("/net10%.0/") then
                dll = candidate
                break
              end
            end

            if not dll then
              dll = dlls[1]
            end

            ----------------------------------------------------------
            -- FINAL DAP CONFIG
            ----------------------------------------------------------

            local dap_config = {
              type = "coreclr",
              name = project_name .. " (" .. profile_name .. ")",
              request = "launch",
              program = dll,
              cwd = project_dir,
              env = env,
              args = args,
            }

            vim.notify("FINAL DAP CONFIG:\n" .. vim.inspect(dap_config))

            ----------------------------------------------------------
            -- Launch debugger
            ----------------------------------------------------------

            dap.run(dap_config)
          end)
        end)
      end
      ----------------------------------------------------------------
      -- Keymaps
      ----------------------------------------------------------------

      vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle breakpoint" })

      vim.keymap.set("n", "<leader>do", dap.step_over, { desc = "DAP: Step over" })

      vim.keymap.set("n", "<leader>di", dap.step_into, { desc = "DAP: Step into" })

      vim.keymap.set("n", "<leader>dc", function()
        if dap.session() then
          dap.continue()
        else
          launch_dotnet_project()
        end
      end, { desc = "DAP: Select Project/Profile" })

      vim.keymap.set("n", "<leader>ds", dap.stop, { desc = "DAP: Stop" })

      vim.keymap.set("n", "<leader>dr", dap.run_to_cursor, { desc = "DAP: Run to cursor" })
    end,
  },
}
