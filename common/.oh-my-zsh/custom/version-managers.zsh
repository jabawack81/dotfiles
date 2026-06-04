# ============================================================================
# version-managers.zsh — interactive cleanup for installed language versions
# ============================================================================
#
# Reclaim disk by uninstalling old rbenv / nodenv / asdf versions through an
# fzf multi-select picker. Each version's preview lists the projects that pin
# it (scanned from your home dir), so you can see what you'd break before you
# delete. The active global default is protected — you can't uninstall it
# directly; promote another version first (Alt-g) and it becomes deletable.
#
# Commands:
#   clean_versions          Detect installed managers and pick which to clean
#   clean_rbenv  [-k N]     Clean rbenv versions  (-k keeps the latest N)
#   clean_nodenv [-k N]     Clean nodenv versions
#   clean_asdf   [-k N]     Clean asdf plugin versions (pick a plugin first)
#   …append -h to any for full help.
#
# Picker keys:  Tab toggle · Alt-g set highlighted as global · Enter confirm
#               · Esc cancel.  The current global is marked with '*'.
#
# Requires:  fzf, plus whichever managers you use (rbenv / nodenv / asdf).
#
# Install (standalone, no dotfiles framework needed):
#   1. Save this file somewhere, e.g. ~/.config/zsh/version-managers.zsh
#   2. Add to ~/.zshrc:   source ~/.config/zsh/version-managers.zsh
#   3. Restart your shell (or `source ~/.zshrc`), then run `clean_versions`.
#   (oh-my-zsh users can instead drop it in ~/.oh-my-zsh/custom/ — it's
#    sourced automatically.)
# ============================================================================

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
  Alt-g          set highlighted version as the global default
  Enter          confirm
  Esc            cancel
The current global is marked with '*'. It can't be uninstalled directly —
use Alt-g to promote a different version first, then it becomes deletable.
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
    # Build preview files (keyed by version, no marker prefix)
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

    # Write a small bash helper that fzf re-runs on every reload to refresh
    # the global-default marker. Doing this in a script (rather than inline
    # in --bind) keeps the global-query live: when Alt-g promotes a new
    # version, the next reload picks up the change.
    cat > "$tmp_dir/list.sh" <<SCRIPT
#!/bin/bash
manager="$manager"
keep_latest=$keep_latest
g=\$("\$manager" global 2>/dev/null | head -1)

versions=()
while IFS= read -r line; do versions+=("\$line"); done \
  < <("\$manager" versions --bare 2>/dev/null | sort -V)

end=\$(( \${#versions[@]} - keep_latest ))
(( end < 0 )) && end=0

for (( i=0; i<end; i++ )); do
  v="\${versions[\$i]}"
  if [[ "\$v" == "\$g" ]]; then echo "* \$v"
  else                          echo "  \$v"
  fi
done
SCRIPT
    chmod +x "$tmp_dir/list.sh"

    local selected
    # Alt-g promotes the highlighted version to be the new global default
    # and reloads the list so the * marker moves. The preview path uses
    # $NF (last whitespace field) so it works for both "* X" and "  X".
    selected=$("$tmp_dir/list.sh" | fzf \
      --multi \
      --prompt="$manager > " \
      --header="Tab: select · Alt-g: set as global · Enter: confirm · Esc: cancel · '*' = global" \
      --preview="cat $tmp_dir/\$(echo {} | awk '{print \$NF}')" \
      --preview-window="right:60%:wrap" \
      --bind="alt-g:execute-silent($manager global \$(echo {} | awk '{print \$NF}'))+reload($tmp_dir/list.sh)")

    if [[ -z "$selected" ]]; then
      echo "No versions selected."
      return 0
    fi

    # Re-query global — Alt-g may have changed it mid-picker.
    local current_global
    current_global=$("$manager" global 2>/dev/null | head -1)

    # Strip the "* " / "  " marker and split into to_remove vs skipped.
    local -a to_remove skipped
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      v="${line##* }"
      if [[ -n "$current_global" && "$v" == "$current_global" ]]; then
        skipped+=( "$v" )
      else
        to_remove+=( "$v" )
      fi
    done <<< "$selected"

    if (( ${#skipped[@]} > 0 )); then
      echo "Skipped (still the current global): ${(j:, :)skipped}"
      echo "Use Alt-g on a different version in the picker first to promote a new global."
      echo ""
    fi

    if (( ${#to_remove[@]} == 0 )); then
      echo "Nothing to uninstall."
      return 0
    fi

    echo "Will uninstall:"
    printf '  %s\n' "${to_remove[@]}"
    echo ""
    printf "Proceed? [y/N]: "
    read -r confirm
    if [[ ! "$confirm" =~ ^[yY] ]]; then
      echo "Aborted."
      return 0
    fi

    for v in "${to_remove[@]}"; do
      echo "→ Uninstalling $v…"
      "$manager" uninstall -f "$v"
    done

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
  Alt-g          set highlighted entry as current/global for its plugin
  Enter          confirm
  Esc            cancel
Current/global entries are marked with '*'. They can't be uninstalled
directly — use Alt-g to promote a different version for that plugin
first, then the old one becomes deletable.
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

    # Write a helper that fzf re-runs on reload to refresh the * markers.
    # Same shape as the rbenv/nodenv version but slightly more involved
    # because each line is "<marker> <plugin> <version>" and the global
    # check is a per-plugin set rather than a single string. Avoid bash 4
    # associative arrays — /bin/bash on macOS is still 3.2; use a temp
    # file + grep -Fx for membership instead.
    cat > "$tmp_dir/list.sh" <<SCRIPT
#!/bin/bash
plugin_filter="$plugin_filter"
keep_latest=$keep_latest

plugins=()
if [[ -n "\$plugin_filter" ]]; then
  plugins=("\$plugin_filter")
else
  while IFS= read -r p; do plugins+=("\$p"); done < <(asdf plugin list 2>/dev/null)
fi

globals_file=\$(mktemp)
asdf current 2>/dev/null | while read -r p v _rest; do
  [[ -z "\$p" || "\$p" == "Name" ]] && continue
  echo "\$p \$v"
done > "\$globals_file"

for plugin in "\${plugins[@]}"; do
  versions=()
  while IFS= read -r line; do
    line=\$(echo "\$line" | sed -E 's/^[[:space:]*]+//')
    [[ -z "\$line" ]] && continue
    versions+=("\$line")
  done < <(asdf list "\$plugin" 2>/dev/null)

  end=\$(( \${#versions[@]} - keep_latest ))
  (( end < 0 )) && end=0

  for (( i=0; i<end; i++ )); do
    entry="\$plugin \${versions[\$i]}"
    if grep -qFx "\$entry" "\$globals_file"; then echo "* \$entry"
    else                                          echo "  \$entry"
    fi
  done
done

rm -f "\$globals_file"
SCRIPT
    chmod +x "$tmp_dir/list.sh"

    local selected
    # Alt-g promotes the highlighted entry to be that plugin's current/global
    # default. The entry is "<marker> <plugin> <version>" — awk's NF-1 and NF
    # give plugin and version reliably for both "* p v" and "  p v" formats.
    # fzf's {} is already shell-escaped — don't add extra quotes around it.
    selected=$("$tmp_dir/list.sh" | fzf \
      --multi \
      --prompt="asdf > " \
      --header="Tab: select · Alt-g: set as global · Enter: confirm · Esc: cancel · '*' = global" \
      --preview="cat \"$tmp_dir/\$(echo {} | awk '{print \$(NF-1), \$NF}')\"" \
      --preview-window="right:60%:wrap" \
      --bind="alt-g:execute-silent(asdf set -u \$(echo {} | awk '{print \$(NF-1), \$NF}'))+reload($tmp_dir/list.sh)")

    if [[ -z "$selected" ]]; then
      echo "No versions selected."
      return 0
    fi

    # Re-query asdf current — Alt-g may have changed which entries are global.
    typeset -A is_global_now
    while read -r cur_plugin cur_version cur_src; do
      [[ -z "$cur_plugin" || "$cur_plugin" == "Name" ]] && continue
      [[ -n "${entry_set[$cur_plugin $cur_version]:-}" ]] && is_global_now["$cur_plugin $cur_version"]=1
    done < <(asdf current 2>/dev/null)

    # Strip the "<marker> " prefix (2 chars) and split into to_remove vs skipped.
    local -a to_remove skipped
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue
      entry="${line:2}"
      if [[ -n "${is_global_now[$entry]:-}" ]]; then
        skipped+=( "$entry" )
      else
        to_remove+=( "$entry" )
      fi
    done <<< "$selected"

    if (( ${#skipped[@]} > 0 )); then
      echo "Skipped (still current/global):"
      printf '  %s\n' "${skipped[@]}"
      echo "Use Alt-g on a different version in the picker first to promote a new global."
      echo ""
    fi

    if (( ${#to_remove[@]} == 0 )); then
      echo "Nothing to uninstall."
      return 0
    fi

    echo "Will uninstall:"
    printf '  %s\n' "${to_remove[@]}"
    echo ""
    printf "Proceed? [y/N]: "
    read -r confirm
    if [[ ! "$confirm" =~ ^[yY] ]]; then
      echo "Aborted."
      return 0
    fi

    for entry in "${to_remove[@]}"; do
      local up=${entry%% *}
      local uv=${entry#* }
      echo "→ Uninstalling $up $uv…"
      asdf uninstall "$up" "$uv"
    done

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
