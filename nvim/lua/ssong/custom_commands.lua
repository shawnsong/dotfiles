-- custom commands

-- Custom command implementation
local M = {}

-- Rginf
local function run_rginf(query)
  local rg_cmd = string.format('rg --column --line-number --no-heading --color=always --smart-case %s ~/work/infrastructure', vim.fn.shellescape(query))
  local files = vim.fn.systemlist(rg_cmd)

  -- Display the files using FZF-Lua
  require('fzf-lua').files({
    cmd = table.concat(files, '\n'),
    actions = {
      ['ctrl-t'] = function(selected)
        vim.cmd(string.format('tabedit %s', selected[2]))
      end
    }
  })
end

return M

