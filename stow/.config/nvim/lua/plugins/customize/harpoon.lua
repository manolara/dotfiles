local harpoon = require 'harpoon'
harpoon:setup()

vim.keymap.set('n', '<leader>ha', function()
  harpoon:list():add()
end)
vim.keymap.set('n', '<leader>hl', function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

-- Set <space>a..<space>g be my shortcuts to moving to the files
-- NOTE TO SELF: if 's' becomes annoying cuz it waits completion from
-- telescope commands condifer <leader>jkl;
for i, idx in ipairs { 'j', 'k', 'l', ';', 'g' } do
  vim.keymap.set('n', string.format('<space>%s', idx), function()
    harpoon:list():select(i)
  end)
end
