------------------------------------------------------------
-- Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

------------------------------------------------------------
-- Basic Options
------------------------------------------------------------
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 300

vim.g.mapleader = " "
vim.g.maplocalleader = " "

------------------------------------------------------------
-- Keymaps
------------------------------------------------------------
vim.keymap.set("n", "<Space><Space>", function()
  require("telescope.builtin").find_files()
end, { desc = "Telescope file search" })

vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { desc = "Telescope live grep" })

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({

  ----------------------------------------------------------
  -- Telescope
  ----------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix = "> ",
          selection_caret = "> ",
          path_display = { "smart" },
        }
      })
    end
  },

  ----------------------------------------------------------
  -- Treesitter
  ----------------------------------------------------------

  ----------------------------------------------------------
  -- LSP
  ----------------------------------------------------------
  
  ----------------------------------------------------------
  -- Autocomplete
  ----------------------------------------------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
        },
      })
    end
  },

  ----------------------------------------------------------
  -- Tsoding Color Scheme (Lua recreation)
  ----------------------------------------------------------
	{
	    "ring0-rootkit/ring0-dark.nvim",
	    priority = 1000, -- Make sure to load this before all the other start plugins.
	    init = function()
		vim.cmd.colorscheme("ring0dark")
	    end,
	},
})

