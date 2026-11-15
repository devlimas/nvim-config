-- Remove o fundo dos temas que não têm opção nativa de transparência.
-- Usa o evento ColorScheme, então reaplica toda vez que o tema é trocado.
local function transparent_on(patterns)
    vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = patterns,
        callback = function()
            for _, group in ipairs({
                "Normal", "NormalNC", "NormalFloat", "SignColumn",
                "EndOfBuffer", "LineNr", "FoldColumn",
            }) do
                vim.api.nvim_set_hl(0, group, { bg = "none" })
            end
        end,
    })
end

return {
    -- ========================================================
    -- TEMA PADRÃO: solarized-osaka (único carregado no startup)
    -- ========================================================
    {
        "craftzdog/solarized-osaka.nvim",
        lazy = false,
        priority = 1000,
        opts = {
            transparent = true,
            terminal_colors = true,
            styles = {
                bold = true,
                comments = { italic = true },
                keywords = { italic = true },
                functions = {},
                variables = {},
                sidebars = "transparent", -- neo-tree, terminal, help...
                floats = "transparent",   -- janelas flutuantes (bom pro blur)
            },
        },
        config = function(_, opts)
            require("solarized-osaka").setup(opts)

            -- Restaura o último tema escolhido (se existir), senão usa o padrão
            local state_path = vim.fn.stdpath("state") .. "/theme.txt"
            local f = io.open(state_path, "r")
            local saved_theme = nil
            if f then
                saved_theme = f:read("*l")
                f:close()
            end

            if saved_theme and saved_theme ~= "" then
                local ok = pcall(vim.cmd.colorscheme, saved_theme)
                if not ok then
                    vim.cmd.colorscheme("solarized-osaka")
                end
            else
                vim.cmd.colorscheme("solarized-osaka")
            end
        end,
    },

    -- ========================================================
    -- DEMAIS TEMAS: carregam sob demanda (:colorscheme nome)
    -- ========================================================
    {
        "folke/tokyonight.nvim",
        lazy = true,
        opts = {
            transparent = true,
            styles = { sidebars = "transparent", floats = "transparent" },
        },
    },

    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = true,
        opts = { transparent_background = true },
    },

    {
        "rebelot/kanagawa.nvim",
        lazy = true,
        opts = { transparent = true },
    },

    {
        "webhooked/kanso.nvim",
        lazy = true,
        opts = { transparent = true },
    },

    {
        "vimcolorschemes/olive-crt.nvim",
        lazy = true,
        init = function() transparent_on("olive-crt") end,
    },

    {
        "zenbones-theme/zenbones.nvim",
        dependencies = "rktjmp/lush.nvim",
        lazy = true,
        init = function()
            vim.g.zenbones_transparent_background = true
        end,
    },

    {
        "uloco/bluloco.nvim",
        dependencies = { "rktjmp/lush.nvim" },
        lazy = true,
        opts = { transparent = true },
    },

    {
        "neanias/everforest-nvim",
        lazy = true,
        opts = {
            background = "hard", -- contraste: "hard", "medium", "soft"
            transparent_background_level = 2, -- 0 = opaco, 1 = transparente, 2 = + sidebars/floats
        },
    },

    {
        "kamwitsta/vinyl.nvim",
        lazy = true,
        opts = {
            transparent = true,
            variant = "darker", -- padrão é "lighter"
            overrides = {
                ["@string"] = { fg = "#00ff00" },
            },
        },
    },

    {
        "rose-pine/neovim",
        name = "rose-pine",
        lazy = true,
        opts = {
            variant = "main", -- "main", "moon" ou "dawn"
            dark_variant = "main",
            styles = {
                bold = true,
                italic = true,
                transparency = true, -- era false, o que anulava o fundo transparente
            },
        },
    },

    {
        "vague-theme/vague.nvim",
        lazy = true,
        opts = {
            transparent = true,
            bold = true,
            italic = true,
            on_highlights = function(hl, colors) end,
            colors = {
                bg = "#141415",
                inactiveBg = "#1c1c24",
                fg = "#cdcdcd",
                floatBorder = "#878787",
                line = "#252530",
                comment = "#606079",
                builtin = "#b4d4cf",
                func = "#c48282",
                string = "#e8b589",
                number = "#e0a363",
                property = "#c3c3d5",
                constant = "#aeaed1",
                parameter = "#bb9dbd",
                visual = "#333738",
                error = "#d8647e",
                warning = "#f3be7c",
                hint = "#7e98e8",
                operator = "#90a0b5",
                keyword = "#6e94b2",
                type = "#9bb4bc",
                search = "#405065",
                plus = "#7fa563",
                delta = "#f3be7c",
            },
        },
    },

    {
        "jpwol/thorn.nvim",
        lazy = true,
        opts = { transparent = true },
    },

    {
        "xero/miasma.nvim",
        lazy = true,
        init = function() transparent_on("miasma") end,
    },

    {
        "morhetz/gruvbox",
        lazy = true,
        init = function() transparent_on("gruvbox") end,
    },

    {
        "tomasr/molokai",
        lazy = true,
        init = function() transparent_on("molokai") end,
    },
}