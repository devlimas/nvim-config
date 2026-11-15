return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    bigfile = { enabled = true },
    explorer = { enabled = false },
    indent = { enabled = true },
    input = { enabled = true },
    picker = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = { enabled = true },
    statuscolumn = { enabled = true },
    words = { enabled = true },

    --configuração do dashboard no snacks
    dashboard = {
      enabled = true,
      preset = {
        -- 1. Seu Banner ASCII
        header = [[
    ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
    ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
    ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
]],
        -- 2. Seus botões idênticos aos do Alpha (usando Telescope)
        keys = {
          { icon = "🔍 ", key = "f", desc = "Procurar Arquivo", action = ":Telescope find_files" },
          { icon = "📄 ", key = "n", desc = "Novo Arquivo", action = ":ene | startinsert" },
          { icon = "🕒 ", key = "r", desc = "Arquivos Recentes", action = ":Telescope oldfiles" },
          { icon = "📂 ", key = "p", desc = "Procurar Projetos", action = ":Telescope projects" },
          { icon = "💤 ", key = "l", desc = "Lazy Plugins", action = ":Lazy" },
          { icon = "❌ ", key = "q", desc = "Sair", action = ":qa" },
        },
      },
    },
  },
}
