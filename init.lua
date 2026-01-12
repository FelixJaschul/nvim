------------------------------------------------------------
-- Bootstrap lazy.nvim
------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
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
vim.keymap.set("n","<Space><Space>",function()
  require("telescope.builtin").find_files()
end)
vim.keymap.set("n","<leader>fg",function()
  require("telescope.builtin").live_grep()
end)
vim.keymap.set("n","<leader>tt","<cmd>ToggleTerm<cr>")
vim.keymap.set("t","<Esc>",[[<C-\><C-n>]])
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
    require("telescope").setup({})
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
      direction = "float",
      open_mapping = [[<c-\>]],
      float_opts = { border = "rounded" },
    })
  end,
},
----------------------------------------------------------
-- Commenting (multi-line)
----------------------------------------------------------
{
  "numToStr/Comment.nvim",
  config = function()
    require("Comment").setup({
      toggler = { line = "<leader>/" },
      opleader = { line = "<leader>/" },
    })
  end,
},
----------------------------------------------------------
-- Gruvbox with Enhanced Python Highlights
----------------------------------------------------------
{
  "morhetz/gruvbox",
  priority = 1000,
  config = function()
     vim.g.gruvbox_contrast_dark = "hard"
     vim.cmd.colorscheme("gruvbox")
    end,
},
----------------------------------------------------------
-- Treesitter with Enhanced Python Support
----------------------------------------------------------
{
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  config = function()
    local ok, ts = pcall(require,"nvim-treesitter.configs")
    if not ok then return end
    ts.setup({
      ensure_installed = { "c","cpp","python","lua","vim","glsl" },
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
    })
  end,
},
----------------------------------------------------------
-- LSP (Neovim 0.11+)
----------------------------------------------------------
{
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "clangd" },
      automatic_installation = false,
    })
    
    vim.lsp.config.clangd = {
      cmd = { "clangd","--background-index" },
      filetypes = { "c","cpp","objc","objcpp" },
      root_markers = { "compile_commands.json","compile_flags.txt",".git" },
    }
    
    -- Use jedi-language-server with full path
    vim.lsp.config["jedi_language_server"] = {
      cmd = { vim.fn.expand("~/Library/Python/3.14/bin/jedi-language-server") },
      filetypes = { "python" },
      root_markers = { "pyproject.toml","setup.py",".git" },
    }
    
    -- Kill unwanted LSP servers
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client then
          -- Kill pyright and pylsp
          if client.name == "pyright" or client.name == "basedpyright" or client.name == "pylsp" then
            vim.lsp.stop_client(client.id)
            return
          end
          
          -- Enable semantic tokens
          if client.server_capabilities.semanticTokensProvider then
            vim.lsp.semantic_tokens.start(args.buf, client.id)
            print(string.format("Semantic tokens enabled for %s", client.name))
          end
        end
      end,
    })
    
    vim.lsp.enable({ "clangd","jedi_language_server" })
  end,
},
})
