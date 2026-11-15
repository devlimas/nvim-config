--[[
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("lazy").load({ plugins = { "neo-tree.nvim" } })
    vim.cmd("Neotree show")
end,
})
]]

--se o nvim for aberto com um diretório como argumento, muda o cwd para ele
vim.api.nvim_create_autocmd("VimEnter", {
  desc = "Ajusta o cwd quando abrimos um diretório",
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= "" and vim.fn.isdirectory(arg) == 1 then
      vim.cmd.cd(arg)
    end
  end,
})

--salva automaticamente ao sair do modo de inserção ou ao perder foco
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = { "*.js", "*.jsx", "*.ts", "*.tsx", "*.html", "*.css", "*.java", "*.lua", "*.py", "*.md", "*.rs" },
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" then
      vim.cmd("silent! w")
    end
  end,
})

vim.o.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "silent! checktime",
})
