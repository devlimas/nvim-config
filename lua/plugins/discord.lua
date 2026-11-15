-- Detecta se há um painel do Codex rodando na janela atual do tmux.
-- Usa cache de 5s para não chamar o tmux a cada atualização da presença.
local cache = { t = 0, v = false }

local function codex_running()
    local now = vim.uv.now()
    if now - cache.t < 5000 then
        return cache.v
    end
    cache.t = now
    cache.v = false
    if vim.env.TMUX then
        local panes = vim.fn.systemlist({ "tmux", "list-panes", "-F", "#{pane_current_command}" })
        for _, cmd in ipairs(panes) do
            if cmd:match("codex") or cmd == "node" then
                cache.v = true
                break
            end
        end
    end
    return cache.v
end

return {
    {
        enabled = true,
        'vyfor/cord.nvim',
        build = ':Cord update',
        opts = {
            user_cmds = true,
            log_level = 'error',
            timer = {
                interval = 1500,
                reset_on_idle = false,
                reset_on_change = false,
            },
            editor = {
                --image = nil,
                client = 'neovim',
                icon = 'https://gitlab.com/repository-lima-group/my-nvim/-/raw/main/codex-logo.png',
                tooltip = 'Codex',
            },
            display = {
                show_time = true,
                show_repository = true,
                show_cursor_position = false,
            },
            text = {
                editing = function(opts)
                    return "Editando " .. opts.filename .. (codex_running() and " com Codex" or "")
                end,
                workspace = function(opts)
                    return "Projeto: " .. opts.workspace .. (codex_running() and " · Codex" or "")
                end,
            },
        },
    },
}
