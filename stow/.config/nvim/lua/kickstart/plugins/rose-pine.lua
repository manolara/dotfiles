return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    priority = 1000,
    init = function()
      -- vim.cmd.colorscheme 'rose-pine'
      -- vim.cmd.hi 'Comment gui=none'
    end,

    opts = {
      styles = {
        bold = true,
        italic = false,
        transparency = false,
      },
      variant = 'main',
    },
  },
}
