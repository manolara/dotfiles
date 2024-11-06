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
    end,
  },
}
