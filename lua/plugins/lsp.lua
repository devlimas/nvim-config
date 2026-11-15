return {

  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
      },
    },
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local lsp_servers = {
        "lua_ls",
        "pyright",
        "vtsls",
        "html",
        "tailwindcss",
        "angularls",
        "cssls",
        "emmet_ls",
        "sqlls",
        "gopls",
        "dockerls",
        "graphql",
        "jsonls",
        "yamlls",

      }

      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      require("mason-lspconfig").setup({
        ensure_installed = lsp_servers,
        automatic_enable = {
          exclude = { "jdtls", "ts_ls" },
        },
      })

      --configuração global de keybinds do LSP (Ativadas quando o LSP se conecta ao buffer)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("UserLspConfig", {}),
        callback = function(ev)
          local opts = { buffer = ev.buf }
          local map = vim.keymap.set

          --documentação e informações
          map("n", "K", vim.lsp.buf.hover, { buffer = ev.buf, desc = "LSP: Hover Docs" })
          map("n", "gs", vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "LSP: Signature Help" })

          --navegação (integrada com Snacks.picker para uma interface moderna)
          map("n", "gd", function() Snacks.picker.lsp_definitions() end, { buffer = ev.buf, desc = "LSP: Ir para Definição" })
          map("n", "gD", vim.lsp.buf.declaration, { buffer = ev.buf, desc = "LSP: Ir para Declaração" })
          map("n", "gi", function() Snacks.picker.lsp_implementations() end, { buffer = ev.buf, desc = "LSP: Ir para Implementação" })
          map("n", "go", function() Snacks.picker.lsp_type_definitions() end, { buffer = ev.buf, desc = "LSP: Tipo da Variável" })
          map("n", "gR", function() Snacks.picker.lsp_references() end, { buffer = ev.buf, desc = "LSP: Buscar Referências" })

          --diagnósticos e ações
          map("n", "gl", vim.diagnostic.open_float, { buffer = ev.buf, desc = "LSP: Ver Erro na Linha" })
          map("n", "<F2>", vim.lsp.buf.rename, { buffer = ev.buf, desc = "LSP: Renomear Símbolo" })
        -- map({ "n", "v" }, "<F3>", function() vim.lsp.buf.format({ async = true }) end, { buffer = ev.buf, desc = "LSP: Formatar Código" })
          map("n", "<F4>", vim.lsp.buf.code_action, { buffer = ev.buf, desc = "LSP: Code Actions" })
        end,
      })

      --configurações específicas de LSPs genéricos
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
          },
        },
      })

      --configuração específica do Angular (precisa de cmd customizado apontando pro node_modules)
      lspconfig.angularls.setup({
        capabilities = capabilities,
        cmd = {
          "ngserver",
          "--stdio",
          "--tsProbeLocations", vim.fn.getcwd() .. "/node_modules",
          "--ngProbeLocations", vim.fn.getcwd() .. "/node_modules",
        },
      })

      --emmet_ls só funciona nos filetypes declarados explicitamente
      lspconfig.emmet_ls.setup({
        capabilities = capabilities,
        filetypes = {
          "html", "css", "scss", "less",
          "javascriptreact", "typescriptreact",
          "typescript", "javascript",
        },
      })

      --jsonls e yamlls: tenta usar schemastore.nvim se estiver instalado
      --(instale com "b0o/schemastore.nvim" no lazy.nvim pra ganhar autocomplete/validação
      --de package.json, tsconfig.json, docker-compose.yml, github actions, etc)
      local ok_schemastore, schemastore = pcall(require, "schemastore")

      lspconfig.jsonls.setup({
        capabilities = capabilities,
        settings = {
          json = {
            schemas = ok_schemastore and schemastore.json.schemas() or {},
            validate = { enable = true },
          },
        },
      })

      lspconfig.yamlls.setup({
        capabilities = capabilities,
        settings = {
          yaml = {
            schemaStore = {
              enable = false, -- desativa a busca online padrão, usamos o schemastore local
              url = "",
            },
            schemas = ok_schemastore and schemastore.yaml.schemas() or {},
          },
        },
      })


      --ativa os servidores genéricos na forma correta do lspconfig
      for _, server in ipairs(lsp_servers) do
        if server ~= "lua_ls" and server ~= "angularls" then
          lspconfig[server].setup({
            capabilities = capabilities,
          })
        end
      end
    end,
  },

  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "mfussenegger/nvim-dap" },
  },

  -- 3. Autocompletar (nvim-cmp)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = false }),
          ["<Tab>"] = cmp.mapping.select_next_item(),

          ["<C-n>"] = cmp.mapping.select_next_item(),
          ["<C-p>"] = cmp.mapping.select_prev_item(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<C-y>"] = cmp.mapping.confirm({ select = false }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },
}

