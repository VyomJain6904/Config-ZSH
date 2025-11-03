local map = vim.keymap.set
local opts = { noremap = true, silent = true, desc = "Description not set" }

-- Save / Quit (clear and correct)
map('n', '<C-s>', ':w<CR>', { noremap = true, desc = 'Save (Ctrl+S)' })
map('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true, desc = 'Save (Ctrl+S)' })
map('n', '<C-q>', ':q<CR>', { noremap = true, desc = 'Quit (Ctrl+Q)' })
map('n', '<C-S-q>', ':qa!<CR>', { noremap = true, desc = 'Quit all (Ctrl+Shift+Q)' })

-- Command palette / find (portable)
map('n', '<C-p>', ':Telescope find_files<CR>', { noremap = true, desc = 'Find files (Ctrl+P)' })
map('n', '<leader>P', ':Telescope commands<CR>', { noremap = true, desc = 'Command palette (leader+P)' })

-- Duplicate/Move line
map('n', '<M-Up>', 'yyP', { desc = 'Duplicate line above (Alt+Up / Meta+Up)' })
map('n', '<M-Down>', 'yyp', { desc = 'Duplicate line below (Alt+Down / Meta+Down)' })
map('n', '<leader>du', 'yyP', { desc = 'Duplicate line above (leader du)' })
map('n', '<leader>dd', 'yyp', { desc = 'Duplicate line below (leader dd)' })

-- Move line up/down (like Alt+Shift+Up/Down)
map({ 'n', 'x' }, '<M-S-Up>', ':move -2<CR>', { desc = 'Move line up (Alt+Shift+Up)' })
map({ 'n', 'x' }, '<M-S-Down>', ':move +1<CR>', { desc = 'Move line down (Alt+Shift+Down)' })
map({ 'n', 'x' }, '<leader>mu', ':move -2<CR>', { desc = 'Move up (leader mu)' })
map({ 'n', 'x' }, '<leader>md', ':move +1<CR>', { desc = 'Move down (leader md)' })

-- Clipboard (+clipboard)
map('v', '<C-c>', '"+y', { desc = 'Copy selection to system clipboard (Ctrl+C)' })
map('v', '<C-x>', '"+d', { desc = 'Cut selection to system clipboard (Ctrl+X)' })
map('n', '<C-v>', '"+p', { desc = 'Paste from system clipboard (Ctrl+V)' })

-- Multicursor (mg979/vim-visual-multi)
vim.g.VM_maps = {}
vim.g.VM_maps['Find Under'] = '<C-d>'
vim.g.VM_maps['Find Subword Under'] = '<C-d>'

-- Terminal toggle
map('n', '<C-`>', ':ToggleTerm<CR>', { noremap = true, desc = 'Toggle terminal (Ctrl+`)' })
map('t', '<C-`>', '<C-\\><C-n>:ToggleTerm<CR>', { noremap = true, desc = 'Toggle terminal (Ctrl+`) in terminal mode' })
map('n', '<leader>t', ':ToggleTerm<CR>', { noremap = true, desc = 'Toggle terminal (leader t)' })

-- Shift+`
map('n', '~', function()
    local ft = vim.bo.filetype
    local cmd_map = {
        python = 'python3',
        javascript = 'node',
        typescript = 'ts-node',
        go = 'go run',
        rust = 'cargo run --',
        sh = 'bash',
    }
    local cmd = cmd_map[ft]
    if cmd then
        vim.cmd('w')
        vim.cmd('!' .. cmd .. ' ' .. vim.fn.shellescape(vim.fn.expand('%')))
    else
        vim.notify('No run command configured for filetype: ' .. ft, vim.log.levels.WARN)
    end
end, { noremap = true, desc = 'Run file (Shift+`) mapped to ~' })

map('n', '<leader>r', ':w<CR>:!bash %<CR>', { noremap = true, desc = 'Run file (leader r)' })
