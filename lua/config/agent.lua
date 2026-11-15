-- Envia seleção, referência de arquivo ou diagnósticos do LSP ao painel do agente de IA (tmux)
-- Funciona com codex, opencode, claude ou qualquer agente aberto no outro painel.
--
-- Atalhos:
--   <leader>cs  (visual)  seleção -> agente (caminho, linhas e código)
--   <leader>cf  (normal)  referência ao arquivo atual -> agente
--   <leader>cd  (normal)  diagnósticos da linha do cursor -> agente
--   <leader>cd  (visual)  diagnósticos das linhas selecionadas -> agente
--   <leader>cD  (normal)  erros e avisos do arquivo inteiro -> agente

local KNOWN = { "codex", "opencode", "claude", "node", "bun" }

-- limites para não inundar o prompt do agente
local MAX_DIAGNOSTICS = 20
local MAX_MESSAGE_CHARS = 600

local function looks_like_agent(cmd)
for _, name in ipairs(KNOWN) do
	if cmd:match(name) then
		return true
		end
		end
		-- o Claude Code às vezes aparece no tmux como um número de versão (ex.: 2.1.0)
		return cmd:match("^%d+%.%d+") ~= nil
		end

		-- Retorna id do painel e o nome do agente (ou nil)
		local function find_agent_pane()
		local lines = vim.fn.systemlist({
			"tmux",
			"list-panes",
			"-t",
			vim.env.TMUX_PANE,
			"-F",
			"#{pane_id}|#{@agent}|#{pane_current_command}",
		})
		local fallback, by_command
		for _, l in ipairs(lines) do
			local id, mark, cmd = l:match("^([^|]*)|([^|]*)|(.*)$")
			if id and id ~= vim.env.TMUX_PANE then
				if mark ~= "" then
					return id, mark
					end
					fallback = fallback or id
					if not by_command and looks_like_agent(cmd) then
						by_command = id
						end
						end
						end
						return by_command or fallback, nil
						end

						local function send(text)
						if not vim.env.TMUX then
							vim.notify("Fora do tmux", vim.log.levels.WARN)
							return
							end
							local pane = find_agent_pane()
							if not pane then
								vim.notify("Painel do agente não encontrado nesta janela", vim.log.levels.WARN)
								return
								end
								-- bracketed paste (-p): quebras de linha não enviam o prompt
								vim.fn.system({ "tmux", "load-buffer", "-b", "nvim-agent", "-" }, text)
								vim.fn.system({ "tmux", "paste-buffer", "-p", "-d", "-b", "nvim-agent", "-t", pane })
								vim.fn.system({ "tmux", "select-pane", "-t", pane })
								end

								-- Linhas selecionadas no modo visual (ordenadas), lidas ANTES de sair do modo
								local function visual_range()
								local s, e = vim.fn.line("v"), vim.fn.line(".")
								if s > e then
									s, e = e, s
									end
									return s, e
									end

									local function leave_visual()
									vim.api.nvim_feedkeys(vim.keycode("<Esc>"), "n", false)
									end

									local function is_visual_mode()
									local mode = vim.fn.mode()
									return mode == "v" or mode == "V" or mode == "\22" -- \22 = CTRL-V (bloco)
									end

									-- ───────────────────────── seleção e arquivo ─────────────────────────

									-- Seleção visual -> agente (com caminho, linhas e código)
									vim.keymap.set("v", "<leader>cs", function()
									local s, e = visual_range()
									local path = vim.fn.expand("%:.")
									local code = table.concat(vim.api.nvim_buf_get_lines(0, s - 1, e, false), "\n")
									send(string.format("@%s (linhas %d-%d):\n```%s\n%s\n```\n", path, s, e, vim.bo.filetype, code))
									leave_visual()
									end, { desc = "Agente: enviar seleção" })

									-- Referência ao arquivo atual -> agente
									vim.keymap.set("n", "<leader>cf", function()
									send("@" .. vim.fn.expand("%:.") .. " ")
									end, { desc = "Agente: enviar arquivo atual" })

									-- ───────────────────────── diagnósticos do LSP ─────────────────────────

									local function severity_label(severity)
									local S = vim.diagnostic.severity
									return ({ [S.ERROR] = "erro", [S.WARN] = "aviso", [S.INFO] = "info", [S.HINT] = "dica" })[severity] or "?"
									end

									-- Monta o texto enviado ao agente: um bloco por diagnóstico, com a linha de código
									local function format_diagnostics(diags, bufnr)
									table.sort(diags, function(a, b)
									if a.lnum ~= b.lnum then
										return a.lnum < b.lnum
										end
										return (a.severity or 9) < (b.severity or 9)
										end)

									local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
									local total = #diags
									local out = { string.format("@%s (diagnósticos do LSP: %d)", path, total), "" }

									for i, d in ipairs(diags) do
										if i > MAX_DIAGNOSTICS then
											break
											end

											local where = tostring(d.lnum + 1)
											if d.end_lnum and d.end_lnum ~= d.lnum then
												where = string.format("%d-%d", d.lnum + 1, d.end_lnum + 1)
												end

												local tag = severity_label(d.severity)
												if d.source and d.source ~= "" then
													tag = tag .. ", " .. d.source
													end
													if d.code ~= nil and d.code ~= "" then
														tag = tag .. " " .. tostring(d.code)
														end

														local msg = d.message or ""
														if #msg > MAX_MESSAGE_CHARS then
															msg = msg:sub(1, MAX_MESSAGE_CHARS) .. "…"
															end
															msg = msg:gsub("\n", "\n    ") -- mensagens de várias linhas ficam indentadas

															table.insert(out, string.format("linha %s [%s]: %s", where, tag, msg))

															local code = vim.api.nvim_buf_get_lines(bufnr, d.lnum, d.lnum + 1, false)[1]
															if code and vim.trim(code) ~= "" then
																table.insert(out, "    > " .. vim.trim(code))
																end
																end

																if total > MAX_DIAGNOSTICS then
																	table.insert(out, string.format("(+%d diagnósticos omitidos)", total - MAX_DIAGNOSTICS))
																	end

																	return table.concat(out, "\n") .. "\n"
																	end

																	-- Linha do cursor (normal) ou linhas selecionadas (visual) -> agente
																	vim.keymap.set({ "n", "v" }, "<leader>cd", function()
																	local bufnr = vim.api.nvim_get_current_buf()
																	local diags

																	if is_visual_mode() then
																		local s, e = visual_range()
																		leave_visual()
																		diags = vim.tbl_filter(function(d)
																		-- pega o diagnóstico se ele encosta em qualquer linha da seleção
																		return d.lnum <= e - 1 and (d.end_lnum or d.lnum) >= s - 1
																		end, vim.diagnostic.get(bufnr))
																		else
																			diags = vim.diagnostic.get(bufnr, { lnum = vim.fn.line(".") - 1 })
																			end

																			if #diags == 0 then
																				vim.notify("Nenhum diagnóstico do LSP aqui", vim.log.levels.INFO)
																				return
																				end
																				send(format_diagnostics(diags, bufnr))
																				end, { desc = "Agente: enviar diagnósticos da linha/seleção" })

																	-- Erros e avisos do arquivo inteiro -> agente (ignora info e dicas)
																	vim.keymap.set("n", "<leader>cD", function()
																	local bufnr = vim.api.nvim_get_current_buf()
																	local diags = vim.diagnostic.get(bufnr, { severity = { min = vim.diagnostic.severity.WARN } })

																	if #diags == 0 then
																		vim.notify("Nenhum erro ou aviso neste arquivo", vim.log.levels.INFO)
																		return
																		end
																		send(format_diagnostics(diags, bufnr))
																		end, { desc = "Agente: enviar erros e avisos do arquivo" })
