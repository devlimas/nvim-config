return {
    {
        enabled = true,
        "mfussenegger/nvim-dap",
        dependencies = {
            "rcarriga/nvim-dap-ui",
            "nvim-neotest/nvim-nio", --dependência exigida pelo dap-ui
            "theHamsta/nvim-dap-virtual-text",
        },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")

            dapui.setup()
            require("nvim-dap-virtual-text").setup()

            --abre/fecha a UI automaticamente ao iniciar/encerrar debug
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
        keys = {
            { "<F5>", function() require("dap").continue() end, desc = "DAP: Continuar/Iniciar" },
            { "<F10>", function() require("dap").step_over() end, desc = "DAP: Step Over" },
            { "<F11>", function() require("dap").step_into() end, desc = "DAP: Step Into" },
            { "<F12>", function() require("dap").step_out() end, desc = "DAP: Step Out" },
            { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "DAP: Toggle Breakpoint" },
            { "<leader>du", function() require("dapui").toggle() end, desc = "DAP: Toggle UI" },
        },
    },
}
