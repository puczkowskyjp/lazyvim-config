return {
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "mfussenegger/nvim-dap",
      "folke/snacks.nvim",
    },
    ft = { "cs", "fsharp", "razor", "sln", "slnx", "csproj", "fsproj" },
    -- stylua: ignore
    keys = {
      { "<leader>Dr", function() require("easy-dotnet").run() end, desc = "Dotnet Run" },
      { "<leader>DR", function() require("easy-dotnet").run_default() end, desc = "Dotnet Run (default project)" },
      { "<leader>Dp", function() require("easy-dotnet").run_profile() end, desc = "Dotnet Run (launch profile)" },
      { "<leader>Dd", function() require("easy-dotnet").debug() end, desc = "Dotnet Debug" },
      { "<leader>DD", function() require("easy-dotnet").debug_profile() end, desc = "Dotnet Debug (launch profile)" },
      { "<leader>Da", function() require("easy-dotnet").debug_attach() end, desc = "Dotnet Debug Attach" },
      { "<leader>Db", function() require("easy-dotnet").build_quickfix() end, desc = "Dotnet Build" },
      { "<leader>Bt", function() require("easy-dotnet").build_solution_quickfix() end, desc = "Dotnet Build Solution" },
      { "<leader>Dt", function() require("easy-dotnet").test() end, desc = "Dotnet Test" },
      { "<leader>Ds", function() require("easy-dotnet").secrets() end, desc = "Dotnet User Secrets" },
      { "<leader>Do", "<cmd>Dotnet outdated<CR>", desc = "Dotnet Outdated Packages" },
    },
    opts = {
      -- Official Roslyn LSP, bundled; replaces seblyng/roslyn.nvim
      lsp = {
        enabled = true,
      },
      debugger = {
        -- nil -> easy-dotnet-server downloads/manages its own netcoredbg build
        bin_path = nil,
        engine = "netcoredbg",
        auto_register_dap = true,
      },
      test_runner = {
        viewmode = "float",
      },
      picker = "snacks",
    },
  },

  -- retained from LazyVim's lang.dotnet extra (now disabled in favor of
  -- easy-dotnet's bundled Roslyn LSP + debugger)
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp", "fsharp" } },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "csharpier", "fantomas" } },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
        fsharp = { "fantomas" },
      },
    },
  },
}
