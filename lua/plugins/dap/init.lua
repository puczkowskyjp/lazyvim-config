local function get_args()
  local args_str = require("dap.utils").splitstr(vim.fn.input("Args: "))
  return args_str
end

-- .NET (coreclr) debugging is handled entirely by easy-dotnet.nvim, which
-- auto-registers its own `dap.adapters.coreclr` and launch-profile-aware
-- configurations (see plugins/dotnet.lua). Use `<leader>Dd`/`<leader>DD`
-- (easy-dotnet's debug/debug_profile) to start a .NET debug session.

return {
  {
    "mfussenegger/nvim-dap",

    dependencies = {
      "mason-org/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },

      -- stylua: ignore
  keys = {
    { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
    { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
    { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
    { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
    { "<leader>dc", function() require("dap").continue() end, desc = "Run/Continue" },
    { "<leader>dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
    { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
    { "<leader>dj", function() require("dap").down() end, desc = "Down" },
    { "<leader>dk", function() require("dap").up() end, desc = "Up" },
    { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
    { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
    { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
    { "<leader>dP", function() require("dap").pause() end, desc = "Pause" },
    { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
    { "<leader>ds", function() require("dap").session() end, desc = "Session" },
    { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
    { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
  },

    config = function()
      if LazyVim.has("mason-nvim-dap.nvim") then
        require("mason-nvim-dap").setup(LazyVim.opts("mason-nvim-dap.nvim"))
      end

      -- `coreclr` intentionally left unmanaged by mason-nvim-dap / mason:
      -- easy-dotnet.nvim bundles and registers its own netcoredbg adapter.

      ----------------------------------------------------------------
      -- go
      ----------------------------------------------------------------

      require("dap-go").setup()
    end,
  },
}
