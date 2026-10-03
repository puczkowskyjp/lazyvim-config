return {
  { "DrKJeff16/wezterm-types" },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    -- dependencies = { "DrKJeff16/wezterm-types" },
    -- opts = {
    --   enabled = function(root_dir)
    --     return vim.g.lazydev_enabled == nil or root_dir:match("%.config[/\\]wezterm") ~= nil
    --   end,
    --   library = {
    --     { path = "${3rd}/luv/library", words = { "vim%.uv" } },
    --     { path = "wezterm-types", mods = { "wezterm" } },
    --   },
    -- },
    opts = function(_, opts)
      opts.library = opts.library or {}
      table.insert(opts.library, {
        path = "wezterm-types",
        mods = { "wezterm" },
      })
      table.insert(opts.library, {
        path = "${3rd}/luv/library",
        words = { "vim%.uv" },
      })
    end,
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
    },
  },
}
