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
        -- coreclr = function() end,
        -- netcoredbg = function() end,
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
      -- 1. Run the default mason-nvim-dap setup
      require("mason-nvim-dap").setup(opts)

      -- 2. Run your custom netcoredbg configuration logic
      vim.notify("Setting up options for nvim-dap", vim.log.levels.INFO)

      local ok, netcoredbg = pcall(require, "plugins.dap.settings.netcoredbg")
      if ok then
        netcoredbg.setup()
      else
        vim.notify("Could not find plugins.dap.settings.netcoredbg module!", vim.log.levels.WARN)
      end
    end,
  },
}
