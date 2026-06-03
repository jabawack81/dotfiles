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
      --preview="cat $tmp_dir/{}" \
      --preview-window="right:60%:wrap")

    if [[ -z "$selected" ]]; then
      echo "No versions selected."
      return 0
    fi

    echo ""
    echo "Will uninstall:"
    printf '%s\n' "$selected" | sed 's/^/  /'
    echo ""

    # Detect whether the user is about to nuke their global default.
    # Without this guard, anything that goes through this manager's shims
    # (next time they open a shell, run npm, run mason, etc.) breaks until
    # they pick a new global.
    local hits_global=false
    if [[ -n "$global_version" ]]; then
      while IFS= read -r v; do
        if [[ "$v" == "$global_version" ]]; then
          hits_global=true
          break
        fi
      done <<< "$selected"
    fi

    if $hits_global; then
      echo "⚠️  This will remove '$global_version' — the current $manager global default."
      echo "   You'll need to run '$manager global <other>' before $manager can resolve again."
      printf "Type the version to confirm removal: "
      read -r confirm
      if [[ "$confirm" != "$global_version" ]]; then
        echo "Aborted."
        return 0
      fi
    else
      printf "Proceed? [y/N]: "
      read -r confirm
      if [[ ! "$confirm" =~ ^[yY] ]]; then
        echo "Aborted."
        return 0
      fi
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

# Interactive cleanup for asdf-managed versions across plugins.
# `clean_asdf` shows "<plugin> <version>" entries via an fzf multi-select picker.
# Pass a plugin name to restrict the picker to that plugin: `clean_asdf ruby`.
# Each entry's preview lists the .tool-versions files pinning it.
function clean_asdf {
  local plugin_filter=""
  local keep_latest=0
  local HELP=false

  # Optional first positional arg = plugin filter (must not look like a flag)
  if [[ -n "${1:-}" && "${1:0:1}" != "-" ]]; then
    plugin_filter=$1
    shift
  fi

  while getopts "k:h" opt; do
    case $opt in
      k) keep_latest=$OPTARG ;;
      h) HELP=true ;;
    esac
  done

  if [[ "$HELP" == true ]]; then
    cat <<EOF
Usage: clean_asdf [PLUGIN] [-k NUM]
  PLUGIN    Restrict picker to a specific plugin (e.g. ruby, nodejs, python)
  -k NUM    Per plugin, pre-exclude the latest NUM versions
  -h        Show this help

Interactive: pick versions to uninstall via fzf.
  Tab/Shift-Tab  toggle selection
  Enter          confirm
  Esc            cancel
Each entry's preview lists .tool-versions files pinning it (one-time ~/ scan).
EOF
    return 0
  fi

  if ! command -v asdf &>/dev/null; then
    echo "Error: asdf not found"
    return 1
  fi
  if ! command -v fzf &>/dev/null; then
    echo "Error: fzf is required for the interactive picker"
    return 1
  fi

  # Which plugins to scan
  local -a plugins
  if [[ -n "$plugin_filter" ]]; then
    if ! asdf plugin list 2>/dev/null | grep -qx "$plugin_filter"; then
      echo "Error: asdf plugin '$plugin_filter' is not installed"
      return 1
    fi
    plugins=( "$plugin_filter" )
  else
    plugins=( ${(@f)"$(asdf plugin list 2>/dev/null)"} )
    if (( ${#plugins[@]} == 0 )); then
      echo "No asdf plugins installed."
      return 0
    fi
  fi

  # Build "<plugin> <version>" entries. `asdf list <plugin>` indents each
  # version and may prefix the current one with `*` — strip both.
  # Hoist loop-locals outside the for so subsequent iterations don't trigger
  # zsh's "re-declared local with existing value" print (which surfaces as
  # spurious lines like "v=3.13.0" before the scan message).
  local -a entries plugin_versions
  local plugin v
  for plugin in "${plugins[@]}"; do
    plugin_versions=( ${(@f)"$(asdf list "$plugin" 2>/dev/null | sed -E 's/^[[:space:]*]+//')"} )

    if (( keep_latest > 0 && keep_latest < ${#plugin_versions[@]} )); then
      plugin_versions=( "${plugin_versions[@]:0:$((${#plugin_versions[@]} - keep_latest))}" )
    fi

    for v in "${plugin_versions[@]}"; do
      [[ -z "$v" ]] && continue
      entries+=( "$plugin $v" )
    done
  done

  if (( ${#entries[@]} == 0 )); then
    echo "No versions to consider."
    return 0
  fi

  # Fast lookup of which entries actually exist (used to filter `asdf current`
  # output which can include placeholders like "Not installed").
  typeset -A entry_set
  local e
  for e in "${entries[@]}"; do entry_set[$e]=1; done

  # Identify global / currently-selected versions per plugin. `asdf current`
  # prints "<plugin>  <version>  <source>" with multi-space padding; read
  # collapses whitespace. Variable names avoid clashing with the loop `v`
  # above so the local declaration doesn't trigger zsh's re-declare echo.
  typeset -A is_global
  local cur_plugin cur_version cur_src
  while read -r cur_plugin cur_version cur_src; do
    [[ -z "$cur_plugin" || "$cur_plugin" == "Name" ]] && continue
    [[ -n "${entry_set[$cur_plugin $cur_version]:-}" ]] && is_global["$cur_plugin $cur_version"]=1
  done < <(asdf current 2>/dev/null)

  # Scan ~/ for .tool-versions files. Each line: "<tool> <version> [...]" —
  # ignore extra fields (legacy fallback versions).
  echo "Scanning ~/ for .tool-versions pins…"
  typeset -A pins_by_entry
  local f line
  while IFS= read -r f; do
    [[ -f "$f" ]] || continue
    while IFS= read -r line; do
      # Skip comments and blanks
      [[ -z "$line" || "${line:0:1}" == "#" ]] && continue
      local fp=${line%% *}
      local rest=${line#* }
      local fv=${rest%% *}
      [[ -z "$fp" || -z "$fv" || "$fp" == "$line" ]] && continue
      pins_by_entry["$fp $fv"]+="$f"$'\n'
    done < "$f"
  done < <(find ~ \
    \( -name node_modules -o -name .git -o -name .asdf -o -name .rbenv -o -name .nodenv \) -prune \
    -o -type f -name ".tool-versions" -print 2>/dev/null)

  local tmp_dir
  tmp_dir=$(mktemp -d)

  {
    local entry marker usage
    for entry in "${entries[@]}"; do
      marker=""
      [[ -n "${is_global[$entry]:-}" ]] && marker=" (global / current)"
      usage="${pins_by_entry[$entry]:-}"
      # Use the entry string verbatim as the filename (incl. space). Fine on
      # any sane FS; the preview command quotes it.
      {
        printf "%s%s\n\n" "$entry" "$marker"
        if [[ -n "$usage" ]]; then
          echo "Pinned by:"
          printf "%s" "$usage" | sed 's/^/  /'
        else
          echo "Not pinned by any .tool-versions under ~/"
        fi
      } > "$tmp_dir/$entry"
    done

    local selected
    # fzf's {} is already shell-escaped (single-quoted) — DO NOT wrap it in
    # extra double quotes here, or the embedded single quotes end up as
    # literal characters in the path lookup.
    selected=$(printf '%s\n' "${entries[@]}" | fzf \
      --multi \
      --prompt="asdf > " \
      --header="Tab: select · Enter: confirm · Esc: cancel" \
      --preview="cat $tmp_dir/{}" \
      --preview-window="right:60%:wrap")

    if [[ -z "$selected" ]]; then
      echo "No versions selected."
      return 0
    fi

    echo ""
    echo "Will uninstall:"
    printf '%s\n' "$selected" | sed 's/^/  /'
    echo ""

    # Detect whether the selection includes any plugin's current/global
    # default. asdf can have one per plugin, so list them all.
    # NB: $entry is already declared `local` higher up — don't redeclare,
    # or zsh will echo its current value (the last-iterated entry).
    local -a hits
    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      [[ -n "${is_global[$entry]:-}" ]] && hits+=( "$entry" )
    done <<< "$selected"

    if (( ${#hits[@]} > 0 )); then
      echo "⚠️  This will remove the current/global default for:"
      printf '   %s\n' "${hits[@]}"
      echo "   You'll need to set a new version for each affected plugin"
      echo "   (e.g. 'asdf set -u <plugin> <version>') before asdf can resolve again."
      printf "Type 'yes' to confirm: "
      read -r confirm
      if [[ "$confirm" != "yes" ]]; then
        echo "Aborted."
        return 0
      fi
    else
      printf "Proceed? [y/N]: "
      read -r confirm
      if [[ ! "$confirm" =~ ^[yY] ]]; then
        echo "Aborted."
        return 0
      fi
    fi

    while IFS= read -r entry; do
      [[ -z "$entry" ]] && continue
      local up=${entry%% *}
      local uv=${entry#* }
      echo "→ Uninstalling $up $uv…"
      asdf uninstall "$up" "$uv"
    done <<< "$selected"

    echo "Done."
  } always {
    [[ -n "$tmp_dir" && -d "$tmp_dir" ]] && rm -rf "$tmp_dir"
  }
}

# Unified entry point: detect which version managers are installed and
# dispatch to the right cleanup command. Skips the tool picker if only one
# is available. For asdf, opens the multi-plugin picker; scope to a single
# plugin with `clean_asdf <plugin>` directly.
function clean_versions {
  local -a available
  command -v rbenv  &>/dev/null && available+=( rbenv )
  command -v nodenv &>/dev/null && available+=( nodenv )
  command -v asdf   &>/dev/null && available+=( asdf )

  if (( ${#available[@]} == 0 )); then
    echo "No supported version managers found (rbenv, nodenv, asdf)."
    return 1
  fi

  local tool
  if (( ${#available[@]} == 1 )); then
    tool="${available[1]}"
    echo "Only $tool is installed — going straight in."
  else
    if ! command -v fzf &>/dev/null; then
      echo "Error: fzf is required to pick between managers"
      echo "Installed: ${available[*]}"
      return 1
    fi
    tool=$(printf '%s\n' "${available[@]}" | fzf \
      --prompt="manager > " \
      --header="Pick a version manager to clean up" \
      --height=30% --reverse)
    [[ -z "$tool" ]] && { echo "Aborted."; return 0; }
  fi

  case "$tool" in
    rbenv|nodenv) clean_version_manager "$tool" "$@" ;;
    asdf)         clean_asdf "$@" ;;
  esac
}
