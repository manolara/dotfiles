-- Highlight todo, notes, etc in comments
return {
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {
      keywords = {
        TODO = { icon = ' ', color = 'hint' },
      },

      signs = false,
      highlight = {
        keyword = 'fg',
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
