-- ftplugin/java.lua
-- Carregado automaticamente pelo Neovim toda vez que um arquivo .java é aberto

local jdtls_ok, jdtls = pcall(require, "jdtls")
if not jdtls_ok then
    return
end

--raiz do Mason (não depende de mason-registry nem de get_install_path, que mudou no Mason 2.x)
local mason_root = (vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")) .. "/packages"
local jdtls_path = mason_root .. "/jdtls"

if vim.fn.isdirectory(jdtls_path) == 0 then
    vim.notify("jdtls não encontrado em " .. jdtls_path .. " (rode :MasonInstall jdtls)", vim.log.levels.ERROR)
    return
end

--java usado para rodar o servidor: o jdtls atual exige Java 21+
--(opcional: defina JDTLS_JAVA_HOME no seu shell pra apontar para um JDK 21+ específico)
--o jdtls atual exige Java 25+: procura um JDK compatível (JDTLS_JAVA_HOME tem prioridade)
local function find_jdtls_java()
    local candidates = {}
    if vim.env.JDTLS_JAVA_HOME then
        table.insert(candidates, vim.env.JDTLS_JAVA_HOME .. "/bin/java")
    end
    for _, dir in ipairs(vim.fn.glob("/usr/lib/jvm/*", true, true)) do
        table.insert(candidates, dir .. "/bin/java")
    end
    table.insert(candidates, "java")

    for _, bin in ipairs(candidates) do
        if vim.fn.executable(bin) == 1 then
            local out = vim.fn.system({ bin, "-version" })
            local major = tonumber(out:match('version "(%d+)'))
            if major and major >= 25 then
                return bin
            end
        end
    end
end

local java_bin = find_jdtls_java()
if not java_bin then
    vim.notify(
        "jdtls precisa de Java 25+ e nenhum foi encontrado. Instale um JDK 25+ (ex.: sudo pacman -S jdk-openjdk) "
            .. "ou defina JDTLS_JAVA_HOME.",
        vim.log.levels.ERROR
    )
    return
end

--bundles de debug e teste (opcionais, só entram se estiverem instalados)
local bundles = {}

vim.list_extend(bundles, vim.fn.glob(
    mason_root .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true
))

--o java-test traz jars que NÃO devem ser carregados como bundle
local excluded = {
    "com.microsoft.java.test.runner-jar-with-dependencies.jar",
    "jacocoagent.jar",
}
for _, jar in ipairs(vim.fn.glob(mason_root .. "/java-test/extension/server/*.jar", true, true)) do
    local name = vim.fn.fnamemodify(jar, ":t")
    if not vim.tbl_contains(excluded, name) then
        table.insert(bundles, jar)
    end
end

--config do launcher conforme o sistema operacional
local os_config = "linux"
if vim.fn.has("mac") == 1 then
    os_config = "mac"
elseif vim.fn.has("win32") == 1 then
    os_config = "win"
end

--jar principal do jdtls (o nome muda a cada versão)
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
if launcher_jar == "" then
    vim.notify("launcher do jdtls não encontrado em " .. jdtls_path .. "/plugins", vim.log.levels.ERROR)
    return
end

--raiz do projeto
local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", "build.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)

if not root_dir or root_dir == "" then
    return
end

--workspace único por projeto (baseado no caminho completo, evita colisão de nomes iguais)
local project_name = root_dir:gsub("[/\\:]", "_")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/workspace/" .. project_name

local capabilities = require("cmp_nvim_lsp").default_capabilities()

local config = {
    cmd = {
        java_bin,
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Xmx1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", launcher_jar,
        "-configuration", jdtls_path .. "/config_" .. os_config,
        "-data", workspace_dir,
    },

    root_dir = root_dir,
    capabilities = capabilities,

    settings = {
        java = {
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    { name = "JavaSE-17", path = "/usr/lib/jvm/java-17-openjdk" },
                    { name = "JavaSE-21", path = "/usr/lib/jvm/java-21-openjdk", default = true },
                    { name = "JavaSE-25", path = "/usr/lib/jvm/java-25-openjdk" },
                    { name = "JavaSE-27", path = "/usr/lib/jvm/java-27-openjdk" },
                },
            },
            signatureHelp = { enabled = true },
            contentProvider = { preferred = "fernflower" },
        },
    },

    init_options = {
        bundles = bundles,
    },

    on_attach = function(client, bufnr)
        require("jdtls").setup_dap({ hotcodereplace = "auto" })
        require("jdtls.dap").setup_dap_main_class_configs()
    end,
}

jdtls.start_or_attach(config)

--keymaps específicos do Java (além dos globais do LspAttach no lsp.lua)
local map = vim.keymap.set
map("n", "<leader>jo", function() jdtls.organize_imports() end, { buffer = 0, desc = "Java: Organizar Imports" })
map("n", "<leader>jv", function() jdtls.extract_variable() end, { buffer = 0, desc = "Java: Extrair Variável" })
map("n", "<leader>jc", function() jdtls.extract_constant() end, { buffer = 0, desc = "Java: Extrair Constante" })
map("n", "<leader>jt", function() jdtls.test_class() end, { buffer = 0, desc = "Java: Rodar Testes da Classe" })
map("n", "<leader>jd", function() jdtls.test_nearest_method() end, { buffer = 0, desc = "Java: Testar Método Próximo" })
