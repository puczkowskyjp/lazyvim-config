-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set
map("n", "<leader>ci", vim.lsp.buf.code_action, { desc = "Auto Import / Code Action" })

-- Diagnostics
map("n", "<leader>ch", vim.diagnostic.open_float, { desc = "Show Details" })

-- map("n", "gd", vim.lsp.buf.definition, { desc = "Go to de:inition" })
-- map("n", "gi", v:vim.lsp.buf.implmentation, { desc = "Go to implmentation" })
