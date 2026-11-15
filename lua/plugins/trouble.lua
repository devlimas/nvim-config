return {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "Trouble",
    opts = {},
    keys = {
        { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnósticos (Trouble)" },
        { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Diagnósticos do Buffer" },
        { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Símbolos" },
        { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
        { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    },
}