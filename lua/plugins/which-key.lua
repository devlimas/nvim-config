return {
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        opts = {
            spec = {
                --registra os títulos dos grupos para a tecla <leader>
                { "<leader>t", group = "Testes (Neotest)" },
                { "<leader>p", group = "Live Preview" },
                { "<leader>v", group = "Python Venv" },
                { "<leader>c", group = "Code / Rust Actions" },
                { "<leader>h", group = "Harpoon Menu" },
                { "<leader>a", group = "IA (Avante)" },
                { "<leader>b", group = "Buffers" },
                { "<leader>d", group = "Debug (DAP)" },
                { "<leader>g", group = "Git" },
                { "<leader>q", group = "Sessão" },
                { "<leader>r", group = "Rodar (Rust / HTTP)" },
                { "<leader>s", group = "Buscar / Janelas" },
                { "<leader>u", group = "Interface" },
                { "<leader>x", group = "Diagnósticos / TODOs" },
            },
        },
    },
}