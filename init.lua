------------------------------------------------------------
-- Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
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

vim.keymap.set("n", "<leader>tt", "<cmd>ToggleTerm<cr>", { desc = "Toggle floating terminal" })
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

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
        },
      })
    end,
  },

  ----------------------------------------------------------
  -- Floating Terminal
  ----------------------------------------------------------
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        open_mapping = [[<c-\>]],
        direction = "float",
        float_opts = {
          border = "rounded",
        },
        shade_terminals = true,
        start_in_insert = true,
        persist_size = true,
      })
    end,
  },

  ----------------------------------------------------------
  -- Tsoding Color Scheme (Lua recreation)
  ----------------------------------------------------------
  {
    "ring0-rootkit/ring0-dark.nvim",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("ring0dark")
    end,
  },

})
