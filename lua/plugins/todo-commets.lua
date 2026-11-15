return {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    keys = {
        { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "TODOs (Trouble)" },
        { "<leader>xT", "<cmd>TodoTelescope<cr>", desc = "TODOs (Telescope)" },
    },
}
