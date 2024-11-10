local ok, lualine = pcall(require, 'lualine')
if not ok then
  return
end

-- local cwd = {
--   function()
--     return vim.fn.getcwd():gsub('^' .. os.getenv 'HOME', '~')
--   end,
--   color = 'LualineCwd',
-- }

local lsp_progress = nil

local function lsp_info()
  if lsp_progress then
    return lsp_progress
  end
  local clients = vim.lsp.get_clients { bufnr = vim.api.nvim_get_current_buf() }
  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
  end
  if #client_names then
    return table.concat(client_names, ', ')
  end
  return 'No Active LSP Clients'
end

-- Custom colours
local custom_vague = require 'plugins.customize.lualine_vague'

local gray_path = '#505050'
local off_black = '#101010'
local normal_bg = custom_vague.command.a.bg
local command_bg = custom_vague.normal.a.bg
local normal_b_fg = custom_vague.command.b.fg
local command_b_fg = custom_vague.normal.b.fg

custom_vague.normal.a.bg = normal_bg
custom_vague.command.a.bg = command_bg
custom_vague.normal.b.fg = normal_b_fg
custom_vague.command.b.fg = command_b_fg

custom_vague.normal.b.fg = '#c6c6ce2'
for _, mode in ipairs { 'normal', 'insert', 'visual', 'command', 'replace' } do
  custom_vague[mode].b.bg = '#202020'
  custom_vague[mode].c.fg = gray_path
  custom_vague[mode].c.bg = off_black
end

lualine.setup {
  options = {
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    globalstatus = true,
    theme = custom_vague,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      { 'branch', component_separators = { left = '' } },
      { 'diff', padding = { left = 0, right = 1 } },
    },
    lualine_c = {
      { 'filetype', icon_only = true, component_separators = { left = '' }, padding = { left = 1, right = 0 } },
      { 'filename', path = 1 },
      -- add line below if you want to start messing with different dirs
      -- cwd,
    },
    lualine_x = {
      {
        'searchcount',
        cond = function()
          local fine, search_count = pcall(vim.fn.searchcount, { recompute = 1 })
          return fine and search_count.total > 0
        end,
      },
    },
    lualine_y = {
      { lsp_info },
      {
        'diagnostics',
        symbols = { error = ' ', warn = ' ', info = ' ', hint = '󰌵 ' },
        padding = { left = 0, right = 1 },
      },
    },
    lualine_z = {
      'location',
      { 'progress', padding = { left = 0, right = 1 } },
    },
  },
}
