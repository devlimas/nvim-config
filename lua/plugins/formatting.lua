return {
    {
        "stevearc/conform.nvim",
        event = { "BufWritePre" },
        cmd = { "ConformInfo" },
        keys = {
            {
                "<F3>",
                function()
                    require("conform").format({
                        timeout_ms = 1000,
                        lsp_fallback = true,
                    })
                end,
                mode = { "n", "v" },
                desc = "Formatar Código (Conform)",
            },
        },
        opts = {
            formatters_by_ft = {
                --backend
                java = { "google-java-format" },
                rust = { "rustfmt" },
                python = { "ruff_format", "isort" },
                lua = { "stylua" },

                --web / full-Stack
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                markdown = { "prettier" },
            },
            format_on_save = {
                timeout_ms = 1000,
                lsp_fallback = true,
            },
        },
    },
}
