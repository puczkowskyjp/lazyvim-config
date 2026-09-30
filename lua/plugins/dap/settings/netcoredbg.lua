local M = {}

local path_join = vim.fs.joinpath

local function get_netcoredbg_path()
  local mason_packages = require("mason.settings").current.install_root_dir
  local package_directory = path_join(mason_packages, "packages", "netcoredbg")

  if vim.fn.has("win32") == 1 then
    return path_join(package_directory, "netcoredbg", "netcoredbg.exe")
  end

  return path_join(package_directory, "netcoredbg")
end

local function get_dll_path()
  local cwd = vim.fn.getcwd()
  local debug_directory = path_join(cwd, "bin", "Debug")
  local raw_matches = vim.fn.glob(path_join(debug_directory, "**", "*.dll"), true, true)
  local launchable_dlls = {}

  for _, path in ipairs(raw_matches) do
    local base_path = path:sub(1, -5)
    local has_runtime_config = vim.uv.fs_stat(base_path .. ".runtimeconfig.json") ~= nil
    local has_dependencies = vim.uv.fs_stat(base_path .. ".deps.json") ~= nil

    if has_runtime_config and has_dependencies then
      table.insert(launchable_dlls, path)
    end
  end

  if #launchable_dlls == 1 then
    return launchable_dlls[1]
  end

  if #launchable_dlls > 1 then
    local choices = { "Select the .NET application to debug:" }
    for _, path in ipairs(launchable_dlls) do
      table.insert(choices, path)
    end
    local selection = vim.fn.inputlist(choices)
    if selection == 0 then
      error("No .NET application target selected")
    end
    return launchable_dlls[selection]
  end

  return vim.fn.input("Path to dll: ", debug_directory .. "/", "file")
end

local function load_launch_settings()
  local settings_path = path_join(vim.fn.getcwd(), "Properties", "launchSettings.json")
  local f = io.open(settings_path, "r")
  if not f then
    return nil
  end
  local content = f:read("*all")
  f:close()
  local ok, parsed = pcall(vim.json.decode, content)
  if not ok or not parsed.profiles then
    return nil
  end
  return parsed.profiles
end

local function build_configurations()
  local configs = {}
  local profiles = load_launch_settings()

  if profiles then
    for profile_name, profile_data in pairs(profiles) do
      local env_vars = {}
      if profile_data.environmentVariables then
        for key, value in pairs(profile_data.environmentVariables) do
          env_vars[key] = value
        end
      end
      if profile_data.applicationUrl then
        env_vars["ASPNETCORE_URLS"] = profile_data.applicationUrl
      end

      table.insert(configs, {
        type = "coreclr",
        name = "NetCoreDbg: " .. profile_name,
        request = "launch",
        cwd = "${workspaceFolder}",
        program = function()
          return get_dll_path()
        end,
        env = env_vars,
        args = {},
      })
    end
  end

  if #configs == 0 then
    table.insert(configs, {
      type = "netcoredbg",
      name = "NetCoreDbg: Default (Development)",
      request = "launch",
      cwd = "${workspaceFolder}",
      program = function()
        return get_dll_path()
      end,
      env = { ASPNETCORE_ENVIRONMENT = "Development" },
      args = {},
    })
  end

  return configs
end

function M.setup()
  vim.notify("Initializing netcoredbg.lua configuration...", vim.log.levels.INFO)
  local dap = require("dap")
  local adapter = {
    type = "executable",
    command = get_netcoredbg_path(),
    args = { "--interpreter=vscode" },
    options = {
      detached = false,
    },
  }

  -- dap.adapters.netcoredbg = adapter
  dap.adapters.coreclr = adapter

  local configs = build_configurations()

  vim.notify("Generated " .. #configs .. " DAP configurations.", vim.log.levels.INFO)

  print("Setup Configs Right Here!", vim.inspect(configs))

  for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
    dap.configurations[lang] = configs
  end
end

-- return M

-- MVP: prove that nvim-dap -> netcoredbg -> .NET DLL works.
function M.setup_mvp()
  local dap = require("dap")

  local netcoredbg = vim.fn.stdpath("data") .. "\\mason\\packages\\netcoredbg\\netcoredbg\\netcoredbg.exe"

  dap.adapters.coreclr = {
    type = "executable",
    command = netcoredbg,
    args = { "--interpreter=vscode" },
    options = {
      detached = false,
    },
  }

  dap.configurations.cs = {
    {
      type = "coreclr",
      name = "MVP - Launch .NET",
      request = "launch",

      program = function()
        return vim.fn.input("Path to DLL: ", vim.fn.getcwd() .. "\\bin\\Debug\\", "file")
      end,
      cwd = "${workspaceFolder}",
    },
  }

  vim.notify("MVP .NET debugger configured", vim.log.levels.INFO)
end

-- Existing setup - leave this commented out while testing MVP.
-- function M.setup()
--   ...
-- end

return M
