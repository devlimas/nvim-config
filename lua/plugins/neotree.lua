return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", --ícones para pastas/arquivos
		"MunifTanjim/nui.nvim",
	},
	keys = {
		{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Alternar Barra Lateral" },
	},
	opts = {
		window = { width = 28 },
		filesystem = {
			group_empty_dirs = true,
			filtered_items = {
				visible = true, --mostra arquivos ocultos (.dotfiles)
			},
		},
	},
	config = function(_, opts)
        -- Aplica as configurações do `opts` ao Neo-tree
        require("neo-tree").setup(opts)

        -- Estilo comum (Branco + Negrito)
        local white_bold = { fg = "#FFFFFF", bold = true }

        -- Aplica para Pastas e Arquivos normais
        vim.api.nvim_set_hl(0, "NeoTreeDirectoryName", white_bold)
        vim.api.nvim_set_hl(0, "NeoTreeFileName", white_bold)

        -- Força arquivos ignorados pelo Git (.gitignore, node_modules, etc.) a ficarem brancos e em negrito
        vim.api.nvim_set_hl(0, "NeoTreeGitIgnored", white_bold)
        vim.api.nvim_set_hl(0, "NeoTreeFileNameOpened", white_bold)
    end,
}
