local entry_display = require 'telescope.pickers.entry_display'
local actions = require 'telescope.actions'
local lga_actions = require 'telescope-live-grep-args.actions'
local transform_mod = require('telescope.actions.mt').transform_mod
local action_state = require 'telescope.actions.state'
local fb = require('telescope').extensions.file_browser
local current_line = action_state.get_current_line()

local function shorten_path(path)
  local cwd = assert(vim.uv.cwd())
  if path == cwd then
    return ''
  end
  local relative_path, replacements = path:gsub('^' .. vim.pesc(cwd .. '/'), '')
  if replacements == 1 then
    return relative_path
  end
  local path_without_home = path:gsub('^' .. vim.pesc(assert(os.getenv 'HOME', '$HOME not set')), '~')
  return path_without_home
end

local function lsp_location_entry_maker(entry)
  local displayer = entry_display.create {
    separator = ' ',
    items = {
      { remaining = true }, -- filename
      { remaining = true }, -- line:col
      { remaining = true }, -- directory
    },
  }

  local function make_display(entry)
    return displayer {
      vim.fs.basename(entry.filename),
      { entry.lnum .. ':' .. entry.col, 'TelescopeResultsLineNr' },
      { shorten_path(vim.fs.dirname(entry.filename)), 'TelescopeResultsLineNr' },
    }
  end

  return {
    valid = true,
    value = entry,
    ordinal = entry.filename .. entry.text,
    display = make_display,
    bufnr = entry.bufnr,
    filename = entry.filename,
    lnum = entry.lnum,
    col = entry.col,
    text = entry.text,
    start = entry.start,
    finish = entry.finish,
  }
end

local ts_select_dir_for_grep = function(live_grep_func)
  fb.file_browser {
    files = false,
    depth = false,
    attach_mappings = function()
      require('telescope.actions').select_default:replace(function()
        local entry_path = action_state.get_selected_entry().Path
        local dir = entry_path:is_dir() and entry_path or entry_path:parent()
        local relative = dir:make_relative(vim.fn.getcwd())
        local absolute = dir:absolute()

        live_grep_func {
          results_title = relative .. '/',
          cwd = absolute,
          default_text = current_line,
        }
      end)

      return true
    end,
  }
end

local custom_actions = transform_mod {
  open_first_qf_item = function(_)
    vim.cmd.cfirst()
  end,
  open_first_loc_item = function(_)
    vim.cmd.lfirst()
  end,
}

require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<c-q>'] = actions.smart_send_to_qflist + actions.open_qflist + custom_actions.open_first_qf_item,
        ['<c-l>'] = actions.smart_send_to_loclist + actions.open_loclist + custom_actions.open_first_loc_item,
        ['<c-w>'] = actions.delete_buffer,
        ['<C-Down>'] = actions.cycle_history_next,
        ['<C-Up>'] = actions.cycle_history_prev,
      },
    },
    history = {
      path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
      limit = 100,
    },
  },
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown(),
    },
    file_browser = {
      theme = 'ivy',
      hijack_netrw = true,
    },
    live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      mappings = { -- extend mappings
        i = {
          ['<C-s>'] = lga_actions.quote_prompt(),
          ['<C-i>'] = lga_actions.quote_prompt { postfix = ' --iglob ' },
          -- freeze the current list and start a fuzzy search in the frozen list
          ['<C-space>'] = actions.to_fuzzy_refine,
          ['<C-f>'] = function()
            ts_select_dir_for_grep(require('telescope').extensions.live_grep_args.live_grep_args)
          end,
        },
        n = {
          ['<C-f>'] = function()
            ts_select_dir_for_grep(require('telescope').extensions.live_grep_args.live_grep_args)
          end,
        },
      },
    },
  },
  pickers = {
    live_grep = {
      mappings = {
        i = {
          ['<C-f>'] = function()
            ts_select_dir_for_grep(require('telescope.builtin').live_grep)
          end,
        },
        n = {
          ['<C-f>'] = function()
            ts_select_dir_for_grep(require('telescope.builtin').live_grep)
          end,
        },
      },
    },
    lsp_document_symbols = {
      entry_maker = function(entry)
        local displayer = entry_display.create {
          separator = ' ',
          items = {
            { width = 13 }, -- symbol type
            { remaining = true }, -- symbol name
          },
        }

        local make_display = function(entry)
          return displayer {
            { entry.symbol_type, 'CmpItemKind' .. entry.symbol_type },
            entry.symbol_name,
          }
        end

        return {
          valid = true,
          value = entry,
          ordinal = entry.text,
          display = make_display,
          filename = entry.filename or vim.api.nvim_buf_get_name(entry.bufnr),
          lnum = entry.lnum,
          col = entry.col,
          symbol_name = entry.text:match '%[.+%]%s+(.*)',
          symbol_type = entry.kind,
          start = entry.start,
          finish = entry.finish,
        }
      end,
    },
    lsp_references = { entry_maker = lsp_location_entry_maker },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension 'live_grep_args')
pcall(require('telescope').load_extension 'smart_history')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<C-p>', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>srg', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<C-f>', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>s/', function()
  builtin.live_grep {
    grep_open_files = true,
    prompt_title = 'Live Grep in Open Files',
  }
end, { desc = '[S]earch [/] in Open Files' })

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function()
  builtin.find_files { cwd = vim.fn.stdpath 'config' }
end, { desc = '[S]earch [N]eovim files' })
