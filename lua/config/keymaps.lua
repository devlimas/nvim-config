local map = vim.keymap.set

--[[
--navegação rápida entre telas segurando Ctrl
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Ir para janela da Esquerda" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Ir para janela de Baixo" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Ir para janela de Cima" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Ir para janela da Direita" })
]]

--limpar destaques de busca
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

--abre a interface completa do Git (LazyGit via Snacks)
vim.keymap.set("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Abrir Lazygit" })

--;ista e navega entre todos os buffers/abas abertas
vim.keymap.set("n", "<leader>fb", function() Snacks.picker.buffers() end, { desc = "Procurar Buffers/Abas" })

--alternar para a próxima aba / aba anterior
vim.keymap.set("n", "]b", "<cmd>bnext<CR>", { silent = true, desc = "Próximo buffer" })
vim.keymap.set("n", "[b", "<cmd>bprevious<CR>", { silent = true, desc = "Buffer anterior" })

--fechar a aba atual sem quebrar o layout das janelas
vim.keymap.set("n", "<leader>bd", ":bd<CR>", { silent = true, desc = "Fechar buffer/aba" })

--busca de símbolos no projeto limitando a requisição para não travar o JDTLS
vim.keymap.set("n", "<leader>ss", function()
  Snacks.picker.lsp_workspace_symbols({
    --filtra tipos mais comuns de Java para a busca não retornar lixo da JDK/dependências
    filter = {
      default = {
        "Class",
        "Interface",
        "Enum",
        "Method",
        "Function",
      },
    },
  })
end, { desc = "Buscar Classes/Métodos no Projeto" })

--busca os símbolos apenas do arquivo atual (para pular direto para um método da classe)
vim.keymap.set("n", "<leader>sS", function() Snacks.picker.lsp_symbols() end, { desc = "Símbolos do Arquivo Atual" })

--busca qualquer texto/função no projeto via Grep (Super rápido)
vim.keymap.set("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep no Projeto (Encontrar Funções)" })

--divisão de janelas de forma intuitiva
vim.keymap.set("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Dividir Janela Verticalmente" })
vim.keymap.set("n", "<leader>sh", "<cmd>split<cr>", { desc = "Dividir Janela Horizontalmente" })
vim.keymap.set("n", "<leader>se", "<C-w>=", { desc = "Igualar Tamanho das Janelas" })
vim.keymap.set("n", "<leader>sx", "<cmd>close<cr>", { desc = "Fechar Janela Atual" })

--alternar terminal flutuante do Snacks
vim.keymap.set({ "n", "t" }, "<C-/>", function() Snacks.terminal() end, { desc = "Alternar Terminal Flutuante" })

--abre o terminal em um split horizontal com <leader>t
vim.keymap.set("n", "<leader>T", "<cmd>split | terminal<CR>i", { desc = "Abre Terminal" })

--sair do modo de inserção do terminal pressionando <Esc>
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Sair do modo terminal" })

--gerenciador de temas com aplicação imediata + persistência
vim.keymap.set("n", "<leader>th", function()
  Snacks.picker.colorschemes({
    confirm = function(picker, item)
      picker:close()
      if item and item.text then
        local theme = item.text

        --salva o tema escolhido no arquivo de estado
        local state_path = vim.fn.stdpath("state") .. "/theme.txt"
        local f = io.open(state_path, "w")
        if f then
          f:write(theme)
          f:close()
        end
      end
    end,
  })
end, { desc = "Gerenciador de Temas (Persistente)" })

