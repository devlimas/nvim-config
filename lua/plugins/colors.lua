return {
    {
        "brenoprata10/nvim-highlight-colors",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            render = "background", --'background', 'foreground' ou 'first_column'
            enable_named_colors = true,
            enable_tailwinds = true, --muito útil para seu fluxo em React / Web
        },
    },
}