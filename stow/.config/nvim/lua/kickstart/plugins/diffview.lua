return {
  {
    'sindrets/diffview.nvim',
    config = function()
      vim.keymap.set('n', '<leader><leader>v', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen'
        else
          vim.cmd 'DiffviewClose'
        end
      end)

      vim.keymap.set('n', '<leader><leader>vm', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen @{upstream}'
        end
      end)
    end,
  },
}
