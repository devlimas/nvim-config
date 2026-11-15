return {
  "brianhuster/live-preview.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  opts = {
    --configurações do live-preview (opcional)
    browser = "brave",
  },
  keys = {
    { "<leader>ps", "<cmd>LivePreview start<cr>", desc = "Iniciar Live Preview" },
    { "<leader>px", "<cmd>LivePreview close<cr>", desc = "Fechar Live Preview" },
    { "<leader>pt", "<cmd>LivePreview toggle<cr>", desc = "Preview: Alternar (Toggle)" },
  },
}
