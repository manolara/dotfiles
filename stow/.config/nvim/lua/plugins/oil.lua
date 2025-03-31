return {
  {
    'stevearc/oil.nvim',
    config = function()
      require 'plugins.customize.oil'
    end,
    -- Optional dependencies
    dependencies = { 'nvim-tree/nvim-web-devicons' },
  },
}
