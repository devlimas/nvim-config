local opt = vim.opt

--[[
vim.cmd("set completeopt=menu,menuone,noselect")
vim.lsp.completion.enable(true)
]]

vim.g.mapleader = " "
vim.g.maplocalleader = " "

--desativa o explorador de arquivos padrão do Neovim (netrw)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.completeopt = { "menu", "menuone", "noselect" }

--desativa a mudança automática de formato/cor do cursor que causa esse bug
vim.opt.guicursor = ""

opt.number = true
opt.relativenumber = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true
opt.smartindent = true
opt.termguicolors = true
opt.ignorecase = true
opt.smartcase = true
opt.signcolumn = "yes"
opt.updatetime = 250
opt.clipboard = "unnamedplus"
opt.wrap = true
opt.linebreak = true
opt.swapfile = false
opt.confirm = true
opt.undofile = true
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.autowrite = true
