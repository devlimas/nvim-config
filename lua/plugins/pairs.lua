return {
    -- 1. Autopairs para parênteses, chaves, colchetes e aspas
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            local npairs = require("nvim-autopairs")

            npairs.setup({
                check_ts = true, -- Usa o Treesitter para verificar o contexto do arquivo
                ts_config = {
                    lua = { "string" },
                    javascript = { "template_string" },
                    typescript = { "template_string" },
                    tsx = { "template_string" },
                    jsx = { "template_string" },
                    java = false,
                    python = false,
                    rust = false,
                    css = false,
                    json = false,
                    html = false,
                },
                fast_wrap = {
                    map = "<M-e>", -- Alt+e para envolver uma palavra existente com um par
                    chars = { "{", "[", "(", '"', "'" },
                    pattern = [=[[%'%"%]%)%}%>]=],
                    end_key = "$",
                    before_key = "h",
                    after_key = "l",
                    cursor_pos_before = true,
                    keys = "qwertyuiopzxcvbnmasdfghjkl",
                    manual_position = true,
                    highlight = "Search",
                    highlight_grey = "Comment",
                },
            })

            -- Integração com o nvim-cmp: insere () automaticamente ao selecionar métodos/funções
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            local cmp_status, cmp = pcall(require, "cmp")
            if cmp_status then
                cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
            end
        end,
    },

    -- 2. Autotag para fechar tags HTML/JSX/TSX automaticamente (ex: <div></div>)
    {
        "windwp/nvim-ts-autotag",
        event = "InsertEnter",
        opts = {
            opts = {
                enable_close = true, -- Fecha a tag automaticamente ao digitar '>'
                enable_rename = true, -- Renomeia a tag de abertura e fechamento juntas
                enable_close_on_slash = true, -- Fecha com '/'
            },
            filetypes = {
                "html",
                "javascript",
                "typescript",
                "javascriptreact",
                "typescriptreact",
                "tsx",
                "jsx",
                "xml",
                "css",
                "java",
            },
        },
    },
}