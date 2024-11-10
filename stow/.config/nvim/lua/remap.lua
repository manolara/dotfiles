local set = vim.keymap.set
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

--  Use CTRL+<hjkl> to switch between windows
set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Nice window resizing
set('n', '<S-D-,>', '<c-w>5<')
set('n', '<S-D-.>', '<c-w>5>')
set('n', '<S-D-t>', '<C-W>+')
set('n', '<S-D-s>', '<C-W>-')

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- IMPORTANT KEYMAPS
set('i', 'jk', '<Esc>', { desc = 'Exit insert Mode' })
set('n', '<C-d>', '<C-d>zz', { desc = 'Recenter after half page down' })
set('n', '<C-u>', '<C-u>zz', { desc = 'Recenter after half page up' })

-- Quickfix
set('n', '<leader>q', function()
  local qf_window_id = vim.fn.getqflist({ winid = 0 }).winid
  local qf_open = qf_window_id > 0
  if qf_open then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end, { desc = 'Toggle quickfix window' })
set('n', ']q', '<cmd>cnext<CR>zz', { desc = ':cnext' })
set('n', '[q', '<cmd>cprev<CR>zz', { desc = ':cprev' })

-- Copy Relative Path
local function copyRelativePath()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  vim.notify('Copied "' .. path .. '" to the clipboard!')
end

set('n', '<leader>rp', copyRelativePath, { desc = 'Get relative path of current buffer' })

-- Yank the Sourcegraph URL
set('n', '<leader>ys', function()
  local git_root = vim.trim(vim.system({ 'git', 'rev-parse', '--show-toplevel' }):wait().stdout)
  local filepath = vim.api.nvim_buf_get_name(0)
  local relative_filepath = filepath:gsub('^' .. git_root .. '/', '')
  local line = unpack(vim.api.nvim_win_get_cursor(0))
  local base_url = vim.env.SOURCEGRAPH_BASE_URL
  if not base_url then
    vim.notify('Unable to yank sourcegraph URL: SOURCEGRAPH_BASE_URL env var not set', vim.log.levels.ERROR)
    return
  end
  local url = string.format('%s/-/blob/%s?L%d', base_url, relative_filepath, line)
  vim.fn.setreg('"', url)
  vim.fn.setreg('*', url)
  print(string.format('Yanked %s', url))
end, { desc = 'Yank the sourcegraph URL to the current position in the buffer' })

-- Execute lua file
set('n', '<leader><leader>x', '<cmd>source %<CR>', { desc = 'Execute the current file' })

-- vim: ts=2 sts=2 sw=2 et
-- --
