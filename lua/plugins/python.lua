return {
    {
        enabled = true,
        "linux-cultist/venv-selector.nvim",
        branch = "regexp", --versão atualizada e estável do plugin
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        ft = "python", --carrega apenas em arquivos Python
        opts = {
            settings = {
                options = {
                    notify_user_on_venv_activation = true,
                },
            },
        },
        keys = {
            { "<leader>vs", "<cmd>VenvSelect<cr>", desc = "Python: Selecionar VirtualEnv" },
            { "<leader>vc", "<cmd>VenvSelectCached<cr>", desc = "Python: Carregar Venv do Cache" },
        },
    },
}
