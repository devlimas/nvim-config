return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local status, configs = pcall(require, "nvim-treesitter.configs")
        if not status then
            return
        end

        configs.setup({
            ensure_installed = { "lua", "vim", "vimdoc", "bash", "json", "markdown", "python", "java", "javascript", "typescript", "html", "css", "c", "c++", "rust", "go", "dockerfile", "yaml", "toml", "jsonc", "graphql", "http", "make", "cmake", "gitignore", "sql", "jsx", "tsx", "php", "ruby", "shell", "swift", "kotlin", "scss", "vue" },
            highlight = { enable = true },
            indent = { enable = true },
        })
    end,
}