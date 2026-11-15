return {
    "folke/persistence.nvim",
    event = "BufReadPre", --carrega antes de abrir um buffer existente
    opts = {},
    keys = {
        {
            "<leader>qs",
            function() require("persistence").load() end,
            desc = "Restaurar Sessão",
        },
        {
            "<leader>ql",
            function() require("persistence").load({ last = true }) end,
            desc = "Restaurar Última Sessão",
        },
        {
            "<leader>qd",
            function() require("persistence").stop() end,
            desc = "Não Salvar Sessão Atual",
        },
    },
}