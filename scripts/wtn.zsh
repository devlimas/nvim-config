# wtn / wtd: criam e removem worktrees git integradas ao tmux-layout
#
# Exemplo de criação de worktree: AGENT=claude wtn feat/x
#
# Raiz do projeto principal (funciona de dentro de qualquer worktree)
_wt_root() {
  local common
  common="$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" || return 1
  print -r -- "${common:h}"
}

# ───────────────────────── wtn: criar ─────────────────────────

# Prepara uma worktree recém-criada: copia os .env e avisa do que falta
_wtn_avisos() {
  local root="$1" dir="$2" f cmd
  local -a avisos=() copiados=()

  # Copia os .env* que existem no projeto principal mas não na worktree
  # (arquivos versionados, como .env.example, já vêm no checkout e são ignorados)
  for f in "$root"/.env*(N.); do
    f="${f:t}"
    if [ ! -e "$dir/$f" ]; then
      cp -p "$root/$f" "$dir/$f" && copiados+=("$f")
    fi
  done

  # Outros arquivos locais (ignorados pelo git) que costumam faltar na worktree.
  # Personalize com:  export WT_COPY_EXTRAS=".claude/settings.local.json .vscode"
  local -a extras
  if [ -n "${WT_COPY_EXTRAS:-}" ]; then
    extras=(${=WT_COPY_EXTRAS})
  else
    extras=(.claude/settings.local.json CLAUDE.local.md .vscode .idea)
  fi
  for f in "${extras[@]}"; do
    if [ -e "$root/$f" ] && [ ! -e "$dir/$f" ]; then
      mkdir -p "$dir/${f:h}" && cp -pR "$root/$f" "$dir/$f" && copiados+=("$f")
    fi
  done

  # Dependências do Node
  if [ -f "$dir/package.json" ] && [ ! -d "$dir/node_modules" ]; then
    cmd="npm install"
    [ -f "$dir/pnpm-lock.yaml" ] && cmd="pnpm install"
    [ -f "$dir/yarn.lock" ] && cmd="yarn install"
    [ -f "$dir/bun.lock" -o -f "$dir/bun.lockb" ] && cmd="bun install"
    avisos+=("instalar dependências:  $cmd")
  fi

  # Ambiente Python
  if [ -f "$dir/pyproject.toml" -o -f "$dir/requirements.txt" ] && [ ! -d "$dir/.venv" ]; then
    avisos+=("recriar o ambiente virtual (.venv)")
  fi

  # Rust: a primeira compilação na worktree é completa
  if [ -f "$dir/Cargo.toml" ] && [ ! -d "$dir/target" ]; then
    avisos+=("primeira compilação será completa:  cargo build")
  fi

  # Nada a fazer: só confirma que a worktree foi criada
  if [ ${#copiados[@]} -eq 0 ] && [ ${#avisos[@]} -eq 0 ]; then
    print -P "\n%F{green}✔ Worktree nova criada:%f ${dir:t}"
    print "  Nada a copiar ou instalar neste projeto."
    sleep 3.5
    return 0
  fi

  print -P "\n%F{yellow}⚠ Worktree nova:%f"
  for f in "${copiados[@]}"; do
    print -P "  %F{green}✔%f copiado: $f"
  done
  for f in "${avisos[@]}"; do
    print "  • $f"
  done
  print ""
  read -k 1 "?Pressione qualquer tecla para abrir o layout... "
  print ""
}

wtn() {
  if [ -z "$1" ]; then
    echo "Uso: wtn <branch>" >&2
    return 1
  fi

  local root dir novo=0
  root="$(_wt_root)" || {
    echo "wtn: você não está dentro de um repositório git" >&2
    return 1
  }
  dir="${root:h}/${root:t}-${1//\//-}"

  # Cria a worktree se ainda não existir:
  #  - branch local ou só no remoto (origin/<branch>): usa/rastreia a existente
  #  - branch nova: nasce a partir da main
  if [ ! -d "$dir" ]; then
    if git show-ref --verify --quiet "refs/heads/$1" \
       || [ -n "$(git for-each-ref --format=x "refs/remotes/*/$1")" ]; then
      git worktree add "$dir" "$1" || return 1
    else
      local base=main
      if ! git show-ref --verify --quiet "refs/heads/main"; then
        if git show-ref --verify --quiet "refs/remotes/origin/main"; then
          base=origin/main
        else
          echo "wtn: branch 'main' não encontrada para servir de base" >&2
          return 1
        fi
      fi
      git worktree add -b "$1" "$dir" "$base" || return 1
    fi
    novo=1
  fi

  # Só prepara (copia arquivos locais e avisa) quando a worktree acabou de ser criada
  [ "$novo" -eq 1 ] && _wtn_avisos "$root" "$dir"

  # Dentro do tmux: se já existe uma janela dessa worktree, só vai até ela
  if [ -n "${TMUX:-}" ]; then
    local wname="${dir:t}" wid
    wname="${wname//[.:]/-}"   # mesmo nome que o tmux-layout usa
    wid="$(tmux list-windows -F '#{window_id} #{window_name}' | awk -v n="$wname" '$2 == n { print $1; exit }')"
    if [ -n "$wid" ]; then
      tmux select-window -t "$wid"
      return 0
    fi
  fi

  cd "$dir" && tmux-layout
}

# ───────────────────────── wtd: remover ─────────────────────────

# Pergunta s/N com uma tecla só
_wtd_confirm() {
  local resp
  read -k 1 "resp?$1 [s/N] "
  print ""
  [[ "$resp" == [sSyY] ]]
}

# Remove uma worktree: tmux, pasta, registro do git e branch
_wtd_remover() {
  local root="$1" dir="$2" branch="$3"
  local name="${dir:t}" sess force=0
  sess="${name//[.:]/-}"   # mesmo nome que o tmux-layout usa

  print -P "%F{cyan}→%f $name"

  # Alterações não commitadas?
  if [ -d "$dir" ] && [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    print -P "  %F{yellow}⚠ alterações não commitadas:%f"
    git -C "$dir" status --short | head -n 8 | sed 's/^/      /'
    _wtd_confirm "  Remover mesmo assim?" || { print "  pulado"; return 1; }
    force=1
  fi

  # Encerra a sessão/janela do tmux dessa worktree (menos a que você está usando)
  if command -v tmux >/dev/null 2>&1; then
    local cur_sess="" cur_win="" wid wname
    if [ -n "${TMUX:-}" ]; then
      cur_sess="$(tmux display -p '#S')"
      cur_win="$(tmux display -p '#{window_id}')"
    fi

    if tmux has-session -t "=$sess" 2>/dev/null; then
      if [ "$sess" = "$cur_sess" ]; then
        print -P "  %F{yellow}!%f a sessão '$sess' é a atual e foi mantida (saia dela com exit)"
      else
        tmux kill-session -t "=$sess" && print "  ✔ sessão tmux encerrada"
      fi
    fi

    if [ -n "${TMUX:-}" ]; then
      tmux list-windows -a -F '#{window_id} #{window_name}' | while read -r wid wname; do
        if [ "$wname" = "$sess" ]; then
          if [ "$wid" = "$cur_win" ]; then
            print -P "  %F{yellow}!%f a janela '$sess' é a atual e foi mantida (feche com exit)"
          else
            tmux kill-window -t "$wid" && print "  ✔ janela tmux encerrada"
          fi
        fi
      done
    fi
  fi

  # Sai da pasta se você estiver dentro dela
  if [[ "$PWD" == "$dir" || "$PWD" == "$dir"/* ]]; then
    cd "$root" || return 1
    print "  ↩ você estava nessa pasta, voltei para ${root:t}"
  fi

  # Remove a worktree
  if [ ! -d "$dir" ]; then
    git -C "$root" worktree prune
  elif [ "$force" -eq 1 ]; then
    git -C "$root" worktree remove --force "$dir" || { print -P "  %F{red}✗ não foi possível remover%f"; return 1; }
  else
    git -C "$root" worktree remove "$dir" || { print -P "  %F{red}✗ não foi possível remover%f"; return 1; }
  fi
  print "  ✔ worktree removida"

  # Apaga a branch (só força se você confirmar)
  if [ -n "$branch" ] && [ "$branch" != "(detached)" ] \
     && git -C "$root" show-ref --verify --quiet "refs/heads/$branch"; then
    if git -C "$root" branch -d "$branch" >/dev/null 2>&1; then
      print "  ✔ branch $branch apagada"
    else
      print -P "  %F{yellow}⚠ '$branch' tem commits não mesclados%f"
      if _wtd_confirm "  Apagar a branch mesmo assim?"; then
        git -C "$root" branch -D "$branch" >/dev/null && print "  ✔ branch $branch apagada"
      else
        print "  branch mantida"
      fi
    fi
  fi
  return 0
}

wtd() {
  local root
  root="$(_wt_root)" || {
    echo "wtd: você não está dentro de um repositório git" >&2
    return 1
  }

  if [[ "${1:-}" == (-h|--help) ]]; then
    print "Uso: wtd               menu para escolher quais remover"
    print "     wtd <branch> ...  remove pelo nome da branch ou da pasta"
    print "     wtd --all         remove todas (pede confirmação)"
    return 0
  fi

  # Lista as worktrees, exceto a principal
  local -a paths=() branches=()
  local line p="" b=""
  while IFS= read -r line; do
    case "$line" in
      "worktree "*) p="${line#worktree }" ;;
      "branch "*)   b="${line#branch refs/heads/}" ;;
      "detached")   b="(detached)" ;;
      "")
        if [ -n "$p" ] && [ "$p" != "$root" ]; then
          paths+=("$p")
          branches+=("${b:-?}")
        fi
        p=""; b="" ;;
    esac
  done < <(git -C "$root" worktree list --porcelain; echo)

  local total=${#paths[@]} i
  if [ "$total" -eq 0 ]; then
    print "Nenhuma worktree além da principal."
    return 0
  fi

  local -a sel=()

  case "${1:-}" in
    -a|--all)
      for ((i = 1; i <= total; i++)); do
        printf '  %d) %-28s %s\n' "$i" "${branches[$i]}" "${paths[$i]}"
        sel+=("$i")
      done
      print ""
      _wtd_confirm "Remover TODAS as $total worktrees?" || { print "cancelado"; return 0; }
      ;;

    "")
      print -P "%F{cyan}Worktrees de ${root:t}:%f"
      for ((i = 1; i <= total; i++)); do
        printf '  %d) %-28s %s\n' "$i" "${branches[$i]}" "${paths[$i]}"
      done
      print ""
      local ans n
      read -r "ans?Números a remover (ex: 1 3), 'a' = todas, Enter = cancelar: "
      [ -z "$ans" ] && { print "cancelado"; return 0; }

      if [[ "$ans" == [aA] ]]; then
        for ((i = 1; i <= total; i++)); do sel+=("$i"); done
        _wtd_confirm "Remover TODAS as $total worktrees?" || { print "cancelado"; return 0; }
      else
        for n in ${=ans}; do
          if [[ "$n" == <-> ]] && [ "$n" -ge 1 ] && [ "$n" -le "$total" ]; then
            sel+=("$n")
          else
            echo "wtd: opção inválida: $n" >&2
            return 1
          fi
        done
      fi
      ;;

    *)
      local alvo achou
      for alvo in "$@"; do
        achou=0
        for ((i = 1; i <= total; i++)); do
          if [ "${branches[$i]}" = "$alvo" ] || [ "${paths[$i]:t}" = "$alvo" ]; then
            sel+=("$i"); achou=1; break
          fi
        done
        if [ "$achou" -eq 0 ]; then
          echo "wtd: worktree não encontrada: $alvo" >&2
          return 1
        fi
      done
      ;;
  esac

  # Remove (sem repetir o mesmo índice)
  local ok=0 fail=0
  local -a feitos=()
  print ""
  for i in "${sel[@]}"; do
    (( ${feitos[(Ie)$i]} )) && continue
    feitos+=("$i")
    if _wtd_remover "$root" "${paths[$i]}" "${branches[$i]}"; then
      ok=$((ok + 1))
    else
      fail=$((fail + 1))
    fi
  done

  git -C "$root" worktree prune
  print -P "\n%F{green}Concluído:%f $ok removida(s), $fail pulada(s)."
}
