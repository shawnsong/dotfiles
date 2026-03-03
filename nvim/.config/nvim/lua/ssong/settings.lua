local g = vim.g
local o = vim.o

-- Makes neovim and host OS clipboard play nicely with each other
o.clipboard = 'unnamedplus'

o.ignorecase = true
o.smartcase = true

o.mouse = 'a'

 -- Better editor UI
o.number = true
o.relativenumber = true
o.numberwidth = 5
o.signcolumn = 'yes:2'
o.cursorline = true

o.termguicolors = true
vim.cmd([[colorscheme base16-gruvbox-dark-pale]])

o.colorcolumn = '120'

-- Better editing experience
o.expandtab = true
o.cindent = true
o.wrap = true
--to keep indenting, use . or use `gv` to to highlight the previous visual selection
o.shiftwidth = 2
o.textwidth = 300
--show existing tab with 2 spaces width
o.tabstop = 2
o.list = true
o.listchars = 'trail:·,nbsp:◇,tab:→ ,extends:▸,precedes:◂'


--when indenting with '>', use 2 spaces width
--in normal mode, highlight the rows and use < or > to indent
--On pressing tab, insert 2 spaces 
-- o.autoindent = true
--indent yaml
-- autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab


o.spell = true
o.spelllang=en_us

--enable rainbow globally
--let g:rainbow_active = 1

--light line configure
o.laststatus=2

-- Better buffer splitting
o.splitright = true
o.splitbelow = true

-- Preserve view while jumping
o.jumpoptions = 'view'

-- Stable buffer content on window open/close events.

if vim.fn.exists('&splitkeep') == 1 and vim.o.splitkeep ~= "cursor" 
  then o.splitkeep = 'screen'
end

g.mapleader = ','
g.maplocalleader = ','

require('lualine').setup({
  options = {
    theme = 'gruvbox'
  }
})

------------------ nvim-tree --------------------------
-- auto close nvim-tree when it's the last buffer
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local invalid_win = {}
    local wins = vim.api.nvim_list_wins()
    for _, w in ipairs(wins) do
      local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
      if bufname:match("NvimTree_") ~= nil then
        table.insert(invalid_win, w)
      end
    end
    if #invalid_win == #wins - 1 then
      -- Should quit, so we close all invalid windows.
      for _, w in ipairs(invalid_win) do vim.api.nvim_win_close(w, true) end
    end
  end
})

-- auto open nvim-tree if it's a file
function open_nvim_tree(data)
  -- buffer is a real file on the disk
  local real_file = vim.fn.filereadable(data.file) == 1

  -- buffer is a [No Name]
  local no_name = data.file == "" and vim.bo[data.buf].buftype == ""

  if not real_file and not no_name then
    return
  end

  -- open the tree, find the file but don't focus it
  require("nvim-tree.api").tree.toggle({ focus = false, find_file = true, })
end
vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree })

-- only open a file in a new tab if it's not in a tab yet
-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach
-- https://github.com/nvim-tree/nvim-tree.lua/wiki/Recipes#automatically-focus-already-opened-file-by-enter-cr
local function my_on_attach(bufnr)
  local function opts(desc)
      return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  local ok, api = pcall(require, "nvim-tree.api")
  assert(ok, "api module is not found")

  api.config.mappings.default_on_attach(bufnr)
  vim.keymap.set("n", "<CR>", api.node.open.tab_drop, opts("Tab drop"))
  vim.keymap.set("n", "<c-t>", api.node.open.tab_drop, opts("Tab drop"))
end
require("nvim-tree").setup({
  hijack_cursor = true,
  sync_root_with_cwd = true,
  sort_by = "case_sensitive",
  reload_on_bufenter = true,
  update_cwd = true,

  on_attach = my_on_attach,

  update_focused_file = {
    enable = true,
  },
  view = {
    width = 60,
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = true,
  },

})
