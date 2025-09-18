-- Automatically run :PackerCompile whenever plugins.lua is updated with an autocommand:
vim.api.nvim_create_autocmd('BufWritePost', {
    group = vim.api.nvim_create_augroup('PACKER', { clear = true }),
    pattern = 'plugins.lua',
    command = 'source <afile> | PackerCompile',
})

return require('packer').startup({
    function(use)
        ---------------------
        -- Package Manager --
        ---------------------

        use('wbthomason/packer.nvim')

        ----------------------
        -- Required plugins --
        ----------------------
        -- Auto pairs
        use('https://github.com/jiangmiao/auto-pairs')


        -- Surround
        use('https://github.com/tpope/vim-surround')
        -- Parentheses Improved
        use('frazrepo/vim-rainbow')

        -- Light line
        use {
          'nvim-lualine/lualine.nvim',
          requires = { 'nvim-tree/nvim-web-devicons', opt = true }
        }
        use('RRethy/nvim-base16')
        use('junegunn/vim-emoji')

        -- Easymosion
        use('easymotion/vim-easymotion')


        -- fzf
        use('junegunn/fzf.vim')
        use('junegunn/fzf')
        use { "ibhagwan/fzf-lua",
          requires = { "nvim-tree/nvim-web-devicons" }
        }

        -- Plug 'neoclide/coc.nvim', {'branch': 'release'}

        -- Plug 'ycm-core/YouCompleteMe'
        -- Plug 'tpope/vim-fugitive'

        -- Plug 'https://github.com/tpope/vim-commentary'

        -- neovim plugins
        use('nvim-tree/nvim-web-devicons')
        use('nvim-tree/nvim-tree.lua')

    end,
    config = {
        display = {
            open_fn = function()
                return require('packer.util').float({ border = 'single' })
            end,
        },
    },
})
