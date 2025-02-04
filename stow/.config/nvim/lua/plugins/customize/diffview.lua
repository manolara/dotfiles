require('diffview').setup {
  vim.opt.fillchars:append { diff = '╱' },
  hooks = {
    diff_buf_win_enter = function(bufnr, winid, ctx)
      if ctx.layout_name:match '^diff2' then
        if ctx.symbol == 'a' then
          vim.opt_local.winhl = table.concat({
            'DiffAdd:DiffviewDiffAddAsDelete',
            'DiffDelete:DiffviewDiffDelete',
          }, ',')
        elseif ctx.symbol == 'b' then
          vim.opt_local.winhl = table.concat({
            'DiffDelete:DiffviewDiffDelete',
          }, ',')
        end
      end
    end,
  },
  enhanced_diff_hl = true,
}

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
