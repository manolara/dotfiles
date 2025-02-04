function FixDiffHighlightColors()
  vim.api.nvim_set_hl(0, 'DiffviewDiffAddAsDelete', { bg = '#431313' })
  vim.api.nvim_set_hl(0, 'DiffDelete', { bg = '#431313' })
  vim.api.nvim_set_hl(0, 'DiffviewDiffDelete', { bg = 'none', fg = '#000000' })
  vim.api.nvim_set_hl(0, 'DiffAdd', { bg = '#1B3028' })
  vim.api.nvim_set_hl(0, 'DiffChange', { bg = '#28304D' })
  vim.api.nvim_set_hl(0, 'DiffText', { bg = '#424674' })
end

return {
  {
    'vague2k/vague.nvim',
    config = function()
      require('vague').setup { -- optional configuration here
        style = {
          comments = 'none',
          strings = 'none',
        },
        colors = {
          bg = '#000000',
        },
      }
      vim.cmd.colorscheme 'vague'
      FixDiffHighlightColors()
    end,
  },
}
