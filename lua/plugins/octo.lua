return {
    "pwntester/octo.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "folke/snacks.nvim", -- você já usa o Snacks.picker no lsp.lua, então reaproveitamos aqui
        "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    event = { { event = "BufReadCmd", pattern = "octo://*" } },
    opts = {
        enable_builtin = true,
        default_merge_method = "squash",
        picker = "snacks", -- usa o mesmo picker que você já tem configurado
    },
    config = function(_, opts)
        -- deixa o treesitter usar o parser de markdown dentro dos buffers do Octo
        vim.treesitter.language.register("markdown", "octo")
        require("octo").setup(opts)
    end,
    keys = {
        { "<leader>gi", "<cmd>Octo issue list<CR>", desc = "Octo: Listar Issues" },
        { "<leader>go", "<cmd>Octo pr list<CR>", desc = "Octo: Abrir PRs" },
    },
}