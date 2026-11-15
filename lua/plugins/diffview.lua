return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewFileHistory",
      "DiffviewRefresh",
    },

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },

    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview: mudanças atuais" }, --mostra tudo que mudou na worktree atual (staged e unstaged). É o que você vai usar mais para revisar o que o agente fez.
      { "<leader>gm", "<cmd>DiffviewOpen main...HEAD<cr>", desc = "Diffview: branch vs main" }, --compara a branch atual com a main (a sintaxe com três pontos mostra só o que a sua branch adicionou). Ótimo antes do merge. Se o seu branch principal se chama master, troque aqui.
      { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview: histórico do arquivo" }, --histórico de commits do arquivo aberto.
      { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: histórico do repo" }, --histórico de commits do repositório inteiro.
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Diffview: fechar" }, --fecha o Diffview.
    },

    opts = {
      enhanced_diff_hl = true,
      view = {
        merge_tool = {
          layout = "diff3_mixed",
        },
      },
    },
  },
}


-- <Tab> / <S-Tab>: próximo/anterior arquivo
-- -: stage/unstage do arquivo sob o cursor
-- S: stage de todos; U: unstage de todos
-- X: descarta as mudanças do arquivo (cuidado, é destrutivo)
-- [x / ]x: conflito anterior/próximo
-- g?: mostra todos os atalhos