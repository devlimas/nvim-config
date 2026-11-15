return {
    {
        "akinsho/bufferline.nvim",
        version = "*",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            options = {
                mode = "buffers",
                diagnostics = "nvim_lsp",
                separator_style = "slope",
                show_buffer_close_icons = false,
                show_close_icon = false,
                always_show_bufferline = true,
            },
            highlights = {
        -- Fundo geral da barra de abas
                fill = {
                    bg = "#011627",
                },

                -- ABAS INATIVAS
                background = {
                    fg = "#d3d3d3",
                    bg = "#034455",
                },
                buffer_visible = {
                    fg = "#708090",
                    bg = "#034455",
                },

        -- ABA SELECIONADA/ATIVA (Garante fundo amarelo em todos os sub-elementos)
                buffer_selected = {
                    fg = "#fefefe",
                    bg = "#b3a20a",
                    bold = true,
                    italic = false,
                },
                numbers_selected = {
                    fg = "#000000",
                    bg = "#8ae068",
                },
                diagnostic_selected = {
                    fg = "#000000",
                    bg = "#e06868",
                },
                hint_selected = {
                    fg = "#000000",
                    bg = "#68e0ca",
                },
                info_selected = {
                    fg = "#000000",
                    bg = "#6e68e0",
                },
                warning_selected = {
                    fg = "#fefefe",
                    bg = "#b3a20a",
                },
                error_selected = {
                    fg = "#fefefe",
                    bg = "#b3a20a",
                },

        -- SEPARADORES (Seta inclinada/slant da aba selecionada)
                separator = {
                    fg = "#011627",
                    bg = "#034455",
                },

                separator_visible = {
                    fg = "#011627",
                    bg = "#034455",
                },
                separator_selected = {
                    fg = "#011627",
                    bg = "#b3a20a", -- Mesmo amarelo da aba ativa
                },

                -- INDICADOR DE MODIFICADO [+]
                modified = {
                    fg = "#fefefe",
                    bg = "#034455",
                },
                modified_visible = {
                    fg = "#41e20b",
                    bg = "#032b38",
                },
                modified_selected = {
                    fg = "#fefefe",
                    bg = "#b3a20a",
                },
            },
        },

    -- Corrige a faixa vazia da barra (tema transparente zera o TabLineFill)
        config = function(_, opts)
            require("bufferline").setup(opts)

            local function set_fill()
                vim.api.nvim_set_hl(0, "TabLineFill", { bg = "#011627" })
                vim.api.nvim_set_hl(0, "BufferLineFill", { bg = "#011627" })
            end

            set_fill()
            vim.api.nvim_create_autocmd("ColorScheme", { callback = set_fill })
        end,

        keys = {
            -- Atalhos práticos para navegar entre as abas
            { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Aba anterior" },
            { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Próxima aba" },
            { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Fixar aba" },
            { "<leader>bc", "<cmd>BufferLinePickClose<cr>", desc = "Fechar aba selecionada" },
        },
    },
}