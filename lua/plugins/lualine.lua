return {
  {
    "nvim-lualine/lualine.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    event = "VeryLazy",
    opts = {
      options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        ------------------------------------------------
        -- ESQUERDA
        ------------------------------------------------
        lualine_a = {
          {
            "mode",
            fmt = function(mode)
              return mode
            end,
          },
        },

        lualine_b = {},

        lualine_c = {
          -- 1. Ícone com fundo destacado e seta explícita para o caminho
          {
            "filetype",
            icon_only = true,
            separator = { right = "" },
            padding = { left = 1, right = 0 },
            color = { bg = "#034455" }, -- Fundo mais claro para criar o contraste necessário
          },

          -- 2. Caminho do arquivo
          {
            "filename",
            path = 4,
            symbols = {
              modified = " [+]",
              readonly = " 󰌾",
              unnamed = "[No Name]",
              newfile = "[New]",
            },
            padding = { left = 1, right = 1 },
          },

          {
            "branch",
            icon = "",
            color = { fg = "#73daca" },
          },

          {
            "diff",
            symbols = {
              added = "+",
              modified = "~",
              removed = "-",
            },
            diff_color = {
              added = { fg = "#9ece6a" },
              modified = { fg = "#e0af68" },
              removed = { fg = "#f7768e" },
            },
          },
        },

        ------------------------------------------------
        -- DIREITA
        ------------------------------------------------
        lualine_x = {
          {
            "diagnostics",
            sources = { "nvim_diagnostic" },
            symbols = {
              error = " ",
              warn = " ",
              info = " ",
              hint = " ",
            },
            diagnostics_color = {
              error = { fg = "#f7768e" },
              warn = { fg = "#e0af68" },
              info = { fg = "#7aa2f7" },
              hint = { fg = "#73daca" },
            },
          },
        },

        lualine_y = {
          { "progress" },
        },

        lualine_z = {
          { "location" },
        },
      },

      inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {
          {
            "filename",
            path = 1,
          },
        },
        lualine_x = { "location" },
        lualine_y = {},
        lualine_z = {},
      },
    },
  },
}