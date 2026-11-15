return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
        current_line_blame = true,
        current_line_blame_opts = { delay = 300 },
        on_attach = function(bufnr)
            local gs = require("gitsigns")
            local function map(mode, lhs, rhs, desc)
                vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
            end

            map("n", "]g", function() gs.nav_hunk("next") end, "Próximo hunk")
            map("n", "[g", function() gs.nav_hunk("prev") end, "Hunk anterior")
            map("n", "<leader>gp", gs.preview_hunk, "Ver hunk")
            map("n", "<leader>gs", gs.stage_hunk, "Stage hunk (aprovar)")
            map("n", "<leader>gr", gs.reset_hunk, "Reverter hunk (rejeitar)")
            map("v", "<leader>gr", function()
                gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
            end, "Reverter trecho selecionado")
        end,
    },
}
