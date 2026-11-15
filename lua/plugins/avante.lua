-- <leader>ap Menu para trocar o agente do avante

-- Agentes disponíveis no Avante (via ACP). A chave é o nome usado em :AvanteSwitchProvider.
local acp_providers = {
    ["codex"] = {
        command = "codex-acp",
        args = {},
        env = {
            NODE_NO_WARNINGS = "1",
            HOME = os.getenv("HOME"),
            PATH = os.getenv("PATH"),
            OPENAI_API_KEY = os.getenv("OPENAI_API_KEY"),
        },
    },

    ["claude-code"] = {
        command = "npx",
        args = { "@zed-industries/claude-code-acp" },
        env = {
            NODE_NO_WARNINGS = "1",
            HOME = os.getenv("HOME"),
            PATH = os.getenv("PATH"),
            ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY"),
        },
    },

    ["opencode"] = {
        command = "opencode",
        args = { "acp" },
    },
}

-- Nome que o tmux-layout usa (AGENT) -> nome do provider do Avante
local agent_aliases = {
    claude = "claude-code",
}

-- Segue o agente do tmux-layout (variável AGENT); se não houver ou não for
-- um provider conhecido, usa o codex.
local function default_provider()
local agent = vim.env.AGENT and vim.env.AGENT:match("%S+") -- só o comando, sem argumentos
agent = agent and (agent_aliases[agent] or agent)
if agent and acp_providers[agent] then
    return agent
    end
    return "codex"
    end

    return {
        {
            "yetone/avante.nvim",
            event = "VeryLazy",
            version = false,

            build = "make",

            dependencies = {
                "nvim-lua/plenary.nvim",
                "MunifTanjim/nui.nvim",
                "nvim-tree/nvim-web-devicons",
                "ColinKennedy/mega.cmdparse",
                "ColinKennedy/mega.logging",
                {
                    "MeanderingProgrammer/render-markdown.nvim",
                    opts = {
                        file_types = { "markdown", "Avante" },
                    },
                    ft = { "markdown", "Avante" },
                },
            },

            -- Menu para trocar de agente durante o uso (além do :AvanteSwitchProvider e do <leader>a?)
            keys = {
                {
                    "<leader>ap",
                    function()
                    local names = vim.tbl_keys(acp_providers)
                    table.sort(names)
                    vim.ui.select(names, { prompt = "Agente do Avante:" }, function(choice)
                    if choice then
                        vim.cmd("AvanteSwitchProvider " .. choice)
                        end
                        end)
                    end,
                    desc = "Avante: escolher agente",
                },
            },

            opts = {
                provider = default_provider(),

                acp_providers = acp_providers,

                mappings = {
                    ask = "<leader>aa",
                    edit = "<leader>ae",
                    refresh = "<leader>ar",
                    focus = "<leader>af",
                    toggle = {
                        default = "<leader>at",
                    },
                },
            },
        },
    }
