-- ~/.config/nvim/lua/plugins/tmux-navigator.lua
-- Ctrl+h/j/k/l anda entre splits do nvim e painéis do tmux sem usar o prefix.
-- Precisa das binds correspondentes no tmux.conf (veja tmux-navigator.conf).
return {
  "christoomey/vim-tmux-navigator",
  cmd = {
    "TmuxNavigateLeft",
    "TmuxNavigateDown",
    "TmuxNavigateUp",
    "TmuxNavigateRight",
    "TmuxNavigatePrevious",
  },
  keys = {
    { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Painel/split à esquerda" },
    { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Painel/split abaixo" },
    { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Painel/split acima" },
    { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Painel/split à direita" },
  },
}
