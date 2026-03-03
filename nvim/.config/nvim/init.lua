-- disable netrw at the very start of your init.lua

if vim.g.vscode then
  require('ssong.plugins')
  require('ssong.settings')
  require('ssong.keybinds')
else
  vim.g.loaded_netrw = 1
  vim.g.loaded_netrwPlugin = 1
  
  require('ssong.plugins')
  require('ssong.settings')
  require('ssong.keybinds')
end
