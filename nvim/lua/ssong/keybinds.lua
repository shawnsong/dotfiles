local function map(m, k, v)
    vim.keymap.set(m, k, v, { silent = true })
end

-- Easymosion
-- change leader to , so 2 chars search is ,,f
map('n', '<Leader><Leader>f', '<Plug>(easymotion-s2)')
map('n', '<Leader><Leader>L', '<Plug>(easymotion-bd-jk)')
map('n', '<Leader><Leader>j', '<Plug>(easymotion-j)')
map('n', '<Leader><Leader>k', '<Plug>(easymotion-k)')
map('n', '<Leader><Leader>l', '<Plug>(easymotion-lineforward)')
map('n', '<Leader><Leader>h', '<Plug>(easymotion-linebackward)')
map('n', '/', '<Plug>(easymotion-sn)')
map('o', '/', '<Plug>(easymotion-tn)')

-- Quit neovim
map('n', '<C-Q>', '<CMD>q<CR>')


-- Copying the vscode behaviour of making tab splits
map('n', '<C-\\>', '<CMD>vsplit<CR>')
map('n', '<A-\\>', '<CMD>split<CR>')

-- move cursor in Insert Mode 
map('i', '<C-h>', '<C-o>h')
map('i', '<C-j>', '<C-o>j')
map('i', '<C-k>', '<C-o>k')
map('i', '<C-l>', '<C-o>l')

-- Make basic movements work better with wrapped lines
vim.keymap.set('n', 'j', 'gj', {noremap=true})
vim.keymap.set('n', 'gj', 'j', {noremap=true})
vim.keymap.set('n', 'k', 'gk', {noremap=true})
vim.keymap.set('n', 'gk', 'k', {noremap=true})

-- so I don't need to use esc
map('i', 'jk', '<ESC>')
map('i', 'JK', '<ESC>')
map('i', 'Jk', '<ESC>')


-- move to the prev/next tab
vim.keymap.set('n', '<C-j>', 'gT', {noremap=true})
vim.keymap.set('n', '<C-k>', 'gt', {noremap=true})

-- go to tabs using number
vim.keymap.set('n', '<leader>1', '1gt', {noremap=true})
vim.keymap.set('n', '<leader>2', '2gt', {noremap=true})
vim.keymap.set('n', '<leader>3', '3gt', {noremap=true})
vim.keymap.set('n', '<leader>4', '4gt', {noremap=true})
vim.keymap.set('n', '<leader>5', '5gt', {noremap=true})
vim.keymap.set('n', '<leader>9', ':tablast<cr>', {noremap=true})

-- quick global search and replace, with/out confirmation
vim.keymap.set('n', '<leader><leader>rr', ':%s///g<Left><Left><Left>', {noremap=true})
vim.keymap.set('n', '<leader><leader>rc', ':%s///gc<Left><Left><Left><Left>', {noremap=true})


-- fzf configurations
vim.keymap.set('n', '<Leader>f', ':Files<CR>', {noremap=true, silent = true })
vim.keymap.set('n', '<C-p>', ':Files<CR>', {noremap=true, silent = true })
-- command! -bang InfFiles call fzf#vim#files('~/work/infrastructure', <bang>0)
-- command! -bang Canva call fzf#vim#files('~/work/canva', <bang>0)



-- nvim-tree
map('n', '<C-n>', ':NvimTreeToggle<CR>')


