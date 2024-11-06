return {
  {
    'stevearc/oil.nvim',
    config = function()
      require('oil').setup {
        skip_confirm_for_simple_edits = true,
        keymaps = {
          -- Disable default mappings
          ['<C-h>'] = false,
          ['<C-l>'] = false,
          ['<C-v>'] = { 'actions.select', opts = { vertical = true }, desc = 'Open the entry in a vertical split' },
        },
        use_default_keymaps = true, -- https://github.com/stevearc/oil.nvim?tab=readme-ov-file#options
      }
      vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })
      -- Override <C-j> and <C-l> to switch panes
      vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Switch to left pane' })
      vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Switch to right pane' })
    end,
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
}
