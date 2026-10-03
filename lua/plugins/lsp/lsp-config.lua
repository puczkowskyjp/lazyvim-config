return {
  -- {
  --   "mason-org/mason.nvim",
  --   config = function()
  --     require("mason").setup()
  --   end,
  --   opts = {
  --     registries = {
  --       "github:mason-org/mason-registry",
  --       "github:Crashdummyy/mason-registry",
  --     },
  --     ensure_installed = {
  --       "shellcheck",
  --       --     "shfmt",
  --       --     "flake8",
  --       "gopls",
  --       "lua-language-server",
  --       --
  --       --     "xmlformatter",
  --       --     "csharpier",
  --       --     "prettier",
  --       --
  --       "stylua",
  --       "bicep-lsp",
  --       "html-lsp",
  --       "css-lsp",
  --       "eslint-lsp",
  --       "typescript-language-server",
  --       "json-lsp",
  --       --
  --       "roslyn",
  --       --
  --       --     "tree-sitter-cli",
  --     },
  --   },
  -- },
  -- {
  --   "mason-org/mason-lspconfig.nvim",
  --   config = function()
  --     require("mason-lspconfig").setup({
  --       ensure_installed = { "lua_ls", "gopls" },
  --     })
  --   end,
  -- },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      { "antosha417/nvim-lsp-file-operations", config = true },
      -- { "folke/neodev.nvim", opts = {} },
      {
        "pmizio/typescript-tools.nvim",
        dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
        config = function()
          require("typescript-tools").setup({})
        end,
      },
    },
    init = function()
      require("snacks.util.lsp").on(function(buffer, _)
        -- stylua: ignore
        vim.keymap.set( "n", "<leader>co", "TypescriptOrganizeImports", { buffer = buffer, desc = "Organize Imports" })
        vim.keymap.set("n", "<leader>cR", "TypescriptRenameFile", { desc = "Rename File", buffer = buffer })
      end)
    end,
    config = function()
      local keymap = vim.keymap -- for conciseness

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          -- Buffer local mappings.
          -- See `:help vim.lsp.*` for documentation on any of the below functions
          local opts = { buffer = ev.buf, silent = true }

          -- set keybinds
          opts.desc = "Show LSP references"
          keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

          opts.desc = "Go to declaration"
          keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

          opts.desc = "Show LSP definitions"
          keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

          opts.desc = "Show LSP implementations"
          keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

          opts.desc = "Show LSP type definitions"
          keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

          opts.desc = "See available code actions"
          keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

          opts.desc = "Smart rename"
          keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

          opts.desc = "Show buffer diagnostics"
          keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

          opts.desc = "Show line diagnostics"
          keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

          opts.desc = "Go to previous diagnostic"
          keymap.set("n", "[d", vim.diagnostic.get_prev, opts) -- jump to previous diagnostic in buffer

          opts.desc = "Go to next diagnostic"
          keymap.set("n", "]d", vim.diagnostic.get_next, opts) -- jump to next diagnostic in buffer

          opts.desc = "Show documentation for what is under cursor"
          keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

          opts.desc = "Restart LSP"
          keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
        end,
      })

      -- used to enable autocompletion (assign to every lsp server config)
      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Change the Diagnostic symbols in the sign column (gutter)
      -- (not in youtube nvim video)
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
      end

      -- Native replacement for the old `mason-lspconfig.setup_handlers()` /
      -- `lspconfig[name].setup()` pattern (deprecated in nvim-lspconfig
      -- v3.0+, see `:h lspconfig-nvim-0.11`). `vim.lsp.config("*", ...)`
      -- applies defaults to every server; per-server overrides below merge
      -- on top of it. `mason-lspconfig.setup()` (default
      -- `automatic_enable = true`) then calls `vim.lsp.enable()` for every
      -- Mason-installed server that maps to a real lspconfig/native config.
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      vim.lsp.config("emmet_ls", {
        filetypes = {
          "html",
          -- "templ",
          "typescriptreact",
          "javascriptreact",
          "css",
          "sass",
          "scss",
          "less",
          -- "svelte",
          -- "vue",
        },
      })

      vim.lsp.config("html", {
        filetypes = { "html", "templ" },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            -- make the language server recognize "vim" global
            diagnostics = {
              globals = { "vim" },
            },
            completion = {
              callSnippet = "Replace",
            },
          },
        },
      })

      require("mason-lspconfig").setup()
    end,
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
  { import = "lazyvim.plugins.extras.lang.typescript" },
}
