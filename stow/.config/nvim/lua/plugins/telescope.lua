return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      {
        'nvim-telescope/telescope-live-grep-args.nvim',
        version = '^1.0.0', -- stable version
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
      { 'nvim-telescope/telescope-file-browser.nvim' },
      { 'nvim-telescope/telescope-smart-history.nvim' },
    },
    config = function()
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      local entry_display = require 'telescope.pickers.entry_display'
      local ts_select_dir_for_grep = function(live_grep_func)
        local action_state = require 'telescope.actions.state'
        local fb = require('telescope').extensions.file_browser
        local current_line = action_state.get_current_line()

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

      local actions = require 'telescope.actions'
      local lga_actions = require 'telescope-live-grep-args.actions'
      local transform_mod = require('telescope.actions.mt').transform_mod
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
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension 'live_grep_args')
      pcall(require('telescope').load_extension 'smart_history')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>srg', ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>", { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
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

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
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
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
