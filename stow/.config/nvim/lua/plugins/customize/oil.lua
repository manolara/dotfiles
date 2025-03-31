local ok, oil = pcall(require, 'oil')
if not ok then
  return
end

local fine, telescope_builtin = pcall(require, 'telescope.builtin')
if not fine then
  print 'telescope shit it self in oil'
  return
end

local get_relative_path = function()
  local path = oil.get_current_dir()
  if not path then
    return
  end
  local current_vim_dir = vim.fn.getcwd()
  local plz_root = vim.fs.root(path, '.plzconfig')
  if plz_root and vim.fs.basename(plz_root) == 'src' then
    current_vim_dir = plz_root
  end
  local relative_path = string.gsub(path, current_vim_dir, '')
  relative_path = relative_path:sub(2, -2)
  return relative_path
end

_G.get_oil_winbar = function()
  return string.rep(' ', 5) .. get_relative_path()
end

oil.setup {
  skip_confirm_for_simple_edits = true,
  win_options = {
    winbar = "%#@attribute.builtin#%{substitute(v:lua.get_oil_winbar(), '^' . $HOME, '~', '')}",
  },
  keymaps = {
    -- Disable some default mappings
    ['<C-h>'] = false,
    ['<C-l>'] = false,
    ['<C-p>'] = false,
    ['<C-v>'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
    -- Custom mappings
    ['<C-P>'] = {
      desc = 'Find files in the current directory',
      function()
        local path = oil.get_current_dir()
        if not path then
          return
        end
        local relative_path = get_relative_path()
        telescope_builtin.find_files {
          prompt_title = 'Find files in ' .. relative_path,
          find_command = { 'fd', '--strip-cwd-prefix', '--follow', '--hidden', '--exclude', '.git' },
          cwd = path,
        }
      end,
      mode = 'n',
      nowait = true,
    },
    ['<C-F>'] = {
      desc = 'Grep in the current directory',
      callback = function()
        local path = oil.get_current_dir()
        if not path then
          return
        end
        local relative_path = get_relative_path()
        telescope_builtin.live_grep {
          results_title = relative_path .. '/',
          cwd = path,
        }
      end,
    },
    ['yf'] = {
      desc = 'Copy file under cursor to system clipboard',
      callback = function()
        local entry = oil.get_cursor_entry()
        if not entry then
          return
        end
        local relative_path = get_relative_path()
        vim.fn.setreg('+', relative_path .. '/' .. entry.name)
      end,
    },
    ['rp'] = {
      desc = 'Copy current folder path to system clipboard',
      callback = function()
        local relative_path = get_relative_path()
        vim.fn.setreg('+', relative_path)
      end,
    },
  },
  use_default_keymaps = true, -- https://github.com/stevearc/oil.nvim?tab=readme-ov-file#options
}
vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
-- Override <C-j> and <C-l> to switch panes
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Switch to left pane' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Switch to right pane' })
