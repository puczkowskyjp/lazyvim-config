-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

vim.opt.shellslash = false
vim.defer_fn(function()
  vim.opt.shellslash = false
end, 5000)
