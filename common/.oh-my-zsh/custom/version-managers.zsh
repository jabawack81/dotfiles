# Interactive cleanup for rbenv / nodenv installed versions.
# `clean_rbenv` / `clean_nodenv` open an fzf multi-select picker;
# each version's preview lists projects pinning it (one-time ~/ scan).

function clean_version_manager {
  local manager=$1
  local keep_latest=0
  local HELP=false

  shift
  while getopts "k:h" opt; do
    case ${opt} in
      k) keep_latest=$OPTARG ;;
      h) HELP=true ;;
    esac
  done

  if [[ "$HELP" == true || -z "$manager" ]]; then
    cat <<EOF
Usage: clean_version_manager MANAGER [-k NUM]
  MANAGER   Version manager (rbenv, nodenv)
  -k NUM    Pre-exclude the latest NUM versions from the picker
  -h        Show this help

Interactive: pick versions to uninstall via fzf.
  Tab/Shift-Tab  toggle selection
  Enter          confirm
  Esc            cancel
Each version's preview lists projects pinning it (slow first scan).
EOF
    return 0
  fi

  if ! command -v "$manager" &>/dev/null; then
    echo "Error: $manager not found"
    return 1
  fi
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is required for the interactive picker"
    return 1
  fi

  local version_file
  case "$manager" in
    rbenv)  version_file=".ruby-version" ;;
    nodenv) version_file=".node-version" ;;
    *) echo "Unknown manager: $manager (expected rbenv or nodenv)"; return 1 ;;
  esac

  local global_version
  global_version=$("$manager" global 2>/dev/null | head -1)

  local -a versions
  versions=( $("$manager" versions --bare 2>/dev/null | sort -V) )
  local total=${#versions[@]}

  if (( keep_latest > 0 && keep_latest < total )); then
    versions=( "${versions[@]:0:$((total - keep_latest))}" )
  fi

  if (( ${#versions[@]} == 0 )); then
    echo "No versions to consider."
    return 0
  fi

  echo "Scanning ~/ for $version_file pins…"
  typeset -A pins_by_version
  local f pinned
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    pinned=$(tr -d '[:space:]' < "$f")
    [[ -z "$pinned" ]] && continue
    pins_by_version[$pinned]+="$f"$'\n'
  done < <(find ~ \
    \( -name node_modules -o -name .git -o -name .rbenv -o -name .nodenv \) -prune \
    -o -type f -name "$version_file" -print 2>/dev/null)

  local tmp_dir
  tmp_dir=$(mktemp -d)

  {
    local v marker usage
    for v in "${versions[@]}"; do
      marker=""
      [[ "$v" == "$global_version" ]] && marker=" (global default)"
      usage="${pins_by_version[$v]}"
      {
        printf "Version: %s%s\n\n" "$v" "$marker"
        if [[ -n "$usage" ]]; then
          echo "Pinned by:"
          printf "%s" "$usage" | sed 's/^/  /'
        else
          echo "Not pinned by any project under ~/"
        fi
      } > "$tmp_dir/$v"
    done

    local selected
    selected=$(printf '%s\n' "${versions[@]}" | fzf \
      --multi \
      --prompt="$manager > " \
      --header="Tab: select · Enter: confirm · Esc: cancel · global: ${global_version:-none}" \
      --preview="cat '$tmp_dir/{}'" \
      --preview-window="right:60%:wrap")

    if [[ -z "$selected" ]]; then
      echo "No versions selected."
      return 0
    fi

    echo ""
    echo "Will uninstall:"
    printf '%s\n' "$selected" | sed 's/^/  /'
    echo ""
    printf "Proceed? [y/N]: "
    read -r confirm
    if [[ ! "$confirm" =~ ^[yY] ]]; then
      echo "Aborted."
      return 0
    fi

    while IFS= read -r v; do
      [[ -z "$v" ]] && continue
      echo "→ Uninstalling $v…"
      "$manager" uninstall -f "$v"
    done <<< "$selected"

    echo "Done."
  } always {
    [[ -n "$tmp_dir" && -d "$tmp_dir" ]] && rm -rf "$tmp_dir"
  }
}

alias clean_rbenv='clean_version_manager rbenv'
alias clean_nodenv='clean_version_manager nodenv'
