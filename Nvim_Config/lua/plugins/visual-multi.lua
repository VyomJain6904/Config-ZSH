-- visual-multi
return {
    { 'mg979/vim-visual-multi', branch = 'master', config = function()
        vim.keymap.set('n','<C-d>','<Plug>(VM-Add-Cursor-Down)',{desc='Add cursor below'})
        vim.keymap.set('v','<C-d>','<Plug>(VM-Add-Cursor-Down)',{desc='Add cursor below'})
        end
    }
}
