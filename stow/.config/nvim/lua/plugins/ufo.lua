return {
  {
    'kevinhwang91/nvim-ufo',
    dependencies = 'kevinhwang91/promise-async',
    event = 'VeryLazy',
    config = function()
      vim.opt.foldlevelstart = 99
      require('ufo').setup()
    end,
  },
}
