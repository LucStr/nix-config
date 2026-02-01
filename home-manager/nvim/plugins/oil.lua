require("oil").setup({
  view_options = {
    show_hidden = true,
  },
  keymaps = {
    ["<C-h>"] = false, -- Disable <C-h>
    ["<C-j>"] = false, -- Disable <C-j> if oil maps it
    ["<C-k>"] = false, -- Disable <C-k> if oil maps it
    ["<C-l>"] = false, -- Disable <C-l> if oil maps it
    ["<C-t>"] = false, -- Disable <C-t> so global telescope binding works
  }
})

