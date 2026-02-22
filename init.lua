-- ------------------------------------------------------------
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

-- Helper for opening Telescope files in splits
local function open_in(split)
  return function()
    -- require Telescope inside the function to avoid preload errors
    local tb = require("telescope.builtin")
    tb.find_files({
      attach_mappings = function(prompt_bufnr, map)
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        local cmd = split == "v" and "vsplit " or split == "h" and "split " or ""

        map("i", "<CR>", function()
          local sel = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.cmd(cmd .. sel.path)
        end)
        map("n", "<CR>", function()
          local sel = action_state.get_selected_entry()
          actions.close(prompt_bufnr)
          vim.cmd(cmd .. sel.path)
        end)

        return true
      end,
    })
  end
end

-- Normal keymaps
vim.keymap.set("n", "<Space><Space>", function()
  require("telescope.builtin").find_files()
end) -- open in current window

vim.keymap.set("n", "vv", open_in("v"))              -- vertical split
vim.keymap.set("n", "hh", open_in("h"))              -- horizontal split
vim.keymap.set("n", "<Space><Enter>", function()
  require("telescope.builtin").live_grep()
end)
vim.keymap.set("n", "<Space>tt", "<cmd>ToggleTerm<cr>")

-- Terminal keymap: type "exit" to close shell
vim.keymap.set("t", "<Esc>", function()
  vim.api.nvim_feedkeys("exit\n", "t", false)
end)

------------------------------------------------------------
-- Plugins
------------------------------------------------------------
require("lazy").setup({
  --------------------------------------------------------
  -- Telescope
  --------------------------------------------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
    end,
  },

  --------------------------------------------------------
  -- Floating Terminal
  --------------------------------------------------------
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

  --------------------------------------------------------
  -- Commenting (single + multi-line)
  --------------------------------------------------------
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup({
        -- keep defaults for multiline: gc, gbc etc.
        toggler = { line = "gcc", block = "gbc" },
        opleader = { line = "gc",  block = "gb"  },
      })
    end,
  },

  --------------------------------------------------------
  -- Gruvbox-baby with TS/LSP support
  --------------------------------------------------------
  {
    -- 1. "morhetz/gruvbox",
    -- 2."folke/tokyonight.nvim",
    -- 3. "nickkadutskyi/jb.nvim",
    -- 4. 'olivercederborg/poimandres.nvim',
    "kdheepak/monochrome.nvim",
    priority = 1000,
    config = function()
      -- vim.cmd.colorscheme("")
      -- 1. vim.cmd.colorscheme("gruvbox")
      -- 2. vim.cmd.colorscheme("tokyonight")
      -- 3. vim.cmd.colorscheme("jb")
      -- 4. vim.cmd.colorscheme("poimandres")
      vim.cmd.colorscheme("monochrome")
    end,
  }, 

  --------------------------------------------------------
  -- Treesitter
  --------------------------------------------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local ok, ts = pcall(require, "nvim-treesitter.configs")
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

  --------------------------------------------------------
  -- LSP (Neovim 0.11+)
  --------------------------------------------------------
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

      -- C/C++: clangd
      vim.lsp.config.clangd = {
        cmd = { "clangd","--background-index" },
        filetypes = { "c","cpp","objc","objcpp" },
        root_markers = { "compile_commands.json","compile_flags.txt",".git" },
      }

      -- Python: jedi-language-server + semantic tokens
      vim.lsp.config["jedi_language_server"] = {
        cmd = { vim.fn.expand("~/Library/Python/3.14/bin/jedi-language-server") },
        filetypes = { "python" },
        root_markers = { "pyproject.toml","setup.py",".git" },
        init_options = {
          semanticTokens = {
            enable = true,
          },
        },
      }

      -- Kill unwanted LSP servers and enable semantic tokens
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          -- Kill pyright / basedpyright / pylsp if they sneak in
          if client.name == "pyright"
            or client.name == "basedpyright"
            or client.name == "pylsp"
          then
            vim.lsp.stop_client(client.id)
            return
          end

          -- Enable semantic tokens if supported
          if client.server_capabilities.semanticTokensProvider then
            vim.lsp.semantic_tokens.start(args.buf, client.id)
            print(string.format("Semantic tokens enabled for %s", client.name))
          end
        end,
      })

      vim.lsp.enable({ "clangd","jedi_language_server" })
    end,
  },
})

