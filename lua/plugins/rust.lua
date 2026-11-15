return {
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    lazy = false,
    config = function()
      local executors = require("rustaceanvim.executors")

      -- Pega as capabilities do nvim-cmp para habilitar o autocomplete no Rust
      local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
      local capabilities = ok_cmp and cmp_lsp.default_capabilities() or {}

      -- Roda um comando do RustLsp usando o vim.ui.select nativo (inputlist),
      -- contornando o bug do snacks.nvim que fecha o picker cedo demais.
      local function rustlsp_native_select(cmd)
        return function()
          local snacks_select = vim.ui.select

          vim.ui.select = function(items, opts, on_choice)
            vim.ui.select = snacks_select -- restaura o Snacks logo em seguida
            opts = opts or {}
            local labels = { opts.prompt or "Selecione:" }
            for i, item in ipairs(items) do
              table.insert(labels, string.format(
                "%d: %s", i,
                opts.format_item and opts.format_item(item) or tostring(item)
              ))
            end
            local choice = vim.fn.inputlist(labels)
            if choice < 1 or choice > #items then
              on_choice(nil)
            else
              on_choice(items[choice], choice)
            end
          end

          vim.cmd.RustLsp(cmd)
        end
      end

      vim.g.rustaceanvim = {
        tools = {
          -- Força a janela do terminal a usar o executor nativo do Neovim
          executor = executors.neovim,
        },
        server = {
          capabilities = capabilities, -- <-- ADICIONADO AQUI PARA O AUTOCOMPLETE FUNCIONAR
          on_attach = function(client, bufnr)
            local map = vim.keymap.set

            -- Runnables usando o fallback nativo + auto-save
            map("n", "<leader>rx", function()
                vim.cmd("w") -- Salva o código
                rustlsp_native_select("runnables")() -- Chama a função nativa com o wrapper
            end, { buffer = bufnr, desc = "Rust: Salva e Executar Código" })

            map("n", "<leader>rD", rustlsp_native_select("debuggables"), { buffer = bufnr, desc = "Rust: Debuggables" })

            -- Esses NÃO usam vim.ui.select, então não precisam do wrapper
            map("n", "<leader>ca", function()
              vim.cmd.RustLsp("codeAction")
            end, { buffer = bufnr, desc = "Rust: Code Actions" })

            map("n", "<leader>ce", function()
              vim.cmd.RustLsp("explainError")
            end, { buffer = bufnr, desc = "Rust: Explicar Erro" })

            map("n", "<leader>rd", function()
              vim.cmd.RustLsp("renderDiagnostic")
            end, { buffer = bufnr, desc = "Rust: Renderizar Diagnóstico" })
          end,
          default_settings = {
            ["rust-analyzer"] = {
              cargo = {
                allFeatures = true,
              },
              checkOnSave = true,
              check = {
                command = "clippy",
              },
            },
          },
        },
      }
    end,
  },
}