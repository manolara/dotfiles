return {
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'catppuccin'
      -- vim.cmd.hi 'Comment gui=none'
    end,

    opts = {
      flavour = 'mocha',
      color_overrides = {
        mocha = {
          base = '#000000',
          green = '#b6ffc5',
        },
        semantic_tokens = true,
      },
      no_italic = true,
      integrations = {
        --https://www.lazyvim.org/plugins/colorscheme in case there is some some integrations cheeze you want to mess around with
        cmp = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { 'undercurl' },
            hints = { 'undercurl' },
            warnings = { 'undercurl' },
            information = { 'undercurl' },
          },
          semantic_tokens = true,
          treesitter_context = true,
        },
      },
    },
  },
}
