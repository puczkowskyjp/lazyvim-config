return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "mason-org/mason.nvim", -- Note: Fixed the repository name here (it's williamboman, not mason-org)
      "mfussenegger/nvim-dap",
    },
    opts = {
      automatic_installation = true,
      handlers = {
        -- function(config)
        --   if config.name ~= "coreclr" and config.name ~= "netcoredbg" then
        --     require("mason-nvim-dap").default_setup(config)
        --   end
        -- end,
      },
      ensure_installed = {
        "netcoredbg",
        -- "coreclr",
      },
    },
    config = function(_, opts)
      vim.notify("Config Opts: ", vim.log.levels.INFO)
      vim.notify(vim.inspect(opts), vim.log.levels.INFO)
      require("mason-nvim-dap").setup(opts)

      vim.notify("Setting up options for nvim-dap", vim.log.levels.INFO)

      local ok, netcoredbg = pcall(require, "plugins.dap.settings.netcoredbg")
      if ok then
        netcoredbg.setup()
      else
        vim.notify("Could not load NetCoreDbg configuration: " .. netcoredbg, vim.log.levels.ERROR)
      end
    end,
  },
}
