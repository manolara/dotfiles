return {
  {
    'marcuscaisey/please.nvim',
    config = function()
      vim.keymap.set('n', '<leader>pb', require('please').build)
      vim.keymap.set('n', '<leader>pr', require('please').run)
      vim.keymap.set('n', '<leader>pt', require('please').test)
      vim.keymap.set('n', '<leader>pct', function()
        require('please').test { under_cursor = true }
      end)
      vim.keymap.set('n', '<leader>pd', require('please').debug)
      vim.keymap.set('n', '<leader>pcd', function()
        require('please').debug { under_cursor = true }
      end)
      vim.keymap.set('n', '<leader>ph', require('please').history)
      vim.keymap.set('n', '<leader>pm', require('please').maximise_popup)
      vim.keymap.set('n', '<leader>pj', require('please').jump_to_target)
      vim.keymap.set('n', '<leader>py', require('please').yank)
    end,
  },
}
