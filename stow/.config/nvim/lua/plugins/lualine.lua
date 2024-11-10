return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons', 'vague2k/vague.nvim' },
    config = function()
      require 'plugins.customize.lualine'
    end,
  },
}
