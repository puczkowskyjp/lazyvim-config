local M = {}

local function get_netcoredbg_path()
  -- return vim.fn.exepath("netcoredbg") ~= "" and vim.fn.exepath("netcoredbg")
  local mason_packages = require("mason.settings").current.install_root_dir
  return (mason_packages .. "\\packages\\netcoredbg\\netcoredbg\\netcoredbg.exe")
end

local function get_dll_path()
  local cwd = vim.fn.getcwd()
  local raw_matches = vim.fn.glob(cwd .. "\\bin\\Debug\\**\\*.dll", true, true)
  for _, path in ipairs(raw_matches) do
    if not path:match("[/\\]obj[/\\]") and not path:match("[/\\]ref[/\\]") and not path:match("[/\\]publish[/\\]") then
      return path
    end
  end
  return vim.fn.input("Path to dll: ", cwd .. "\\bin\\Debug\\", "file")
end

local function load_launch_settings()
  local settings_path = vim.fn.getcwd() .. "\\Properties\\launchSettings.json"
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
        type = "netcoredbg",
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

  dap.adapters.netcoredbg = adapter
  -- dap.adapters.coreclr = adapter

  local configs = build_configurations()

  vim.notify("Generated " .. #configs .. " DAP configurations.", vim.log.levels.INFO)

  print("Setup Configs Right Here!", vim.inspect(configs))

  for _, lang in ipairs({ "cs", "fsharp", "vb" }) do
    dap.configurations[lang] = configs
  end
end

return M
