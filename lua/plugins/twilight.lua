return {
    {
        "folke/twilight.nvim",
        cmd = { "Twilight", "TwilightEnable", "TwilightDisable" },
        opts = {
            dimming = {
                alpha = 0.50, --nível de transparência do código inativo (0 a 1)
            },
            context = 25, --quantas linhas em volta do bloco manter visíveis
            treesitter = true, --usa o parser do Treesitter para identificar os blocos
            expand = {
                "method_declaration",
                "constructor_declaration",
                "annotation",
                "function_definition",
                "function_declaration",
            },
        },
        keys = {
            { "<leader>uw", "<cmd>Twilight<cr>", desc = "Alternar Modo Twilight (Foco)" },
        },
    },
}