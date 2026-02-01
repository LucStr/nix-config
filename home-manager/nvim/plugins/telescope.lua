local actions = require('telescope.actions')

-- Send to quickfix and open Trouble with folds collapsed
local function send_to_trouble(prompt_bufnr)
  actions.smart_send_to_qflist(prompt_bufnr)
  vim.cmd('Trouble qflist open')
  vim.defer_fn(function()
    require("trouble").fold_close_all()
  end, 50)
end

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ["<C-q>"] = send_to_trouble,
      },
      n = {
        ["<C-q>"] = send_to_trouble,
      },
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,                    -- false will only do exact matching
      override_generic_sorter = true,  -- override the generic sorter
      override_file_sorter = true,     -- override the file sorter
      case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                       -- the default case_mode is "smart_case"
    }
  }
})

require('telescope').load_extension('fzf')