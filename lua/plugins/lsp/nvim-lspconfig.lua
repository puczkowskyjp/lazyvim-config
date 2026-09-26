return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
    -- opts = {
    --   registries = {
    --     "github:mason-org/mason-registry",
    --     "github:Crashdummyy/mason-registry",
    --   },
    --   ensure_installed = {
    --     "shellcheck",
    --     "shfmt",
    --     "flake8",
    --
    --     "lua-language-server",
    --
    --     "xmlformatter",
    --     "csharpier",
    --     "prettier",
    --
    --     "stylua",
    --     "bicep-lsp",
    --     "html-lsp",
    --     "css-lsp",
    --     "eslint-lsp",
    --     "typescript-language-server",
    --     "json-lsp",
    --
    --     "roslyn",
    --
    --     "tree-sitter-cli",
    --   },
    -- },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls" },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      lspconfig.lua_ls.setup({})
    end,
    -- dependencies = {
    --   "mason-org/mason.nvim",
    --   { "mason-org/mason-lspconfig.nvim", config = function() end },
    --   -- init = function()
    --   --   require("lazyvim.util").lsp.on_attach(function(_, buffer)
    --   --     -- stylua: ignore
    --   --     vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
    --   --     vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
    --   --   end)
    --   -- end,
    -- -- },
    -- ---@class PluginLspOpts
    -- opts = {
    --   ---@type lspconfig.options
    --   servers = {
    --     -- tsserver will be automatically installed with mason and loaded with lspconfig
    --     tsserver = {},
    --   },
    --   -- you can do any additional lsp server setup here
    --   -- return true if you don't want this server to be setup with lspconfig
    --   ---@type table<string, fun(server:string, opts:_.lspconfig.options):boolean?>
    --   setup = {
    --     -- example to setup with typescript.nvim
    --     tsserver = function(_, opts)
    --       require("typescript").setup({ server = opts })
    --       return true
    --     end,
    --     -- Specify * to use this function as a fallback for any server
    --     -- ["*"] = function(server, opts) end,
    --   },
    -- },
  },

  -- change trouble config
  {
    "folke/trouble.nvim",
    -- opts will be merged with the parent spec
    opts = { use_diagnostic_signs = true },
  },

  -- disable trouble
  --{ "folke/trouble.nvim", enabled = false },

  -- for typescript, LazyVim also includes extra specs to properly setup lspconfig,
  -- treesitter, mason and typescript.nvim. So instead of the above, you can use:
  -- { import = "lazyvim.plugins.extras.lang.typescript" },
}
