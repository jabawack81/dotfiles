function until_failure {
  local MAX_RUNS=10
  local NOTIFY=false
  local MESSAGE="Max runs reached"
  local HELP=false
  local start_time=$(date +%s)
  local exit_code=0

  while getopts "m:r:nh" opt; do
    case ${opt} in
    m) MESSAGE=$OPTARG ;;
    r) MAX_RUNS=$OPTARG ;;
    n) NOTIFY=true ;;
    h) HELP=true ;;
    esac
  done
  shift $((OPTIND - 1))

  if [ "$HELP" = true ] || [ $# -eq 0 ]; then
    echo "Usage: until_failure [-r runs] [-m message] [-n] command [args...]"
    echo "  -r NUM    Maximum number of runs (default: 10)"
    echo "  -m MSG    Notification message (default: 'Max runs reached')"
    echo "  -n        Send notification via ntfy.sh when done"
    echo "  -h        Show this help message"
    echo ""
    echo "Example: until_failure -r 50 -n -m 'Tests finally failed!' npm test"
    return 0
  fi

  local i=0
  echo "############################################################################################"

  while "$@"; do
    exit_code=$?
    if [ $exit_code -ne 0 ]; then
      local end_time=$(date +%s)
      local elapsed=$((end_time - start_time))
      echo "Command failed with exit code: $exit_code"
      echo "Failed after $((i + 1)) runs in $elapsed seconds"
      if [ "$NOTIFY" = true ]; then
        curl -sS -d "Command failed after $((i + 1)) runs (exit: $exit_code)" ntfy.sh/$NTFY_TOPIC >>/dev/null
      fi
      return $exit_code
    fi
    
    echo "Run number: $((i + 1))/$MAX_RUNS - Success"
    echo "############################################################################################"
    let i=$i+1
    if [ $i -eq $MAX_RUNS ]; then
      local end_time=$(date +%s)
      local elapsed=$((end_time - start_time))
      echo "Max runs reached - command succeeded $MAX_RUNS times in $elapsed seconds"
      if [ "$NOTIFY" = true ]; then
        curl -sS -d "${MESSAGE} - succeeded $MAX_RUNS times" ntfy.sh/$NTFY_TOPIC >>/dev/null
      fi
      break
    fi
  done
}

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

# Convenience aliases
alias clean_rbenv='clean_version_manager rbenv'
alias clean_nodenv='clean_version_manager nodenv'

# One-shot brew refresh: fetch metadata, upgrade everything, reclaim disk.
# `brew cleanup -s` removes old formula versions left after upgrade and
# scrubs the download cache. `brew autoremove` then drops dependencies
# no longer required by any explicitly-installed formula.
do_the_brew_thing() {
  echo "first we update"
  brew update || return 1
  echo "then we upgrade"
  brew upgrade
  echo "then we tidy up"
  brew cleanup -s
  echo "then we drop orphaned deps"
  brew autoremove
}

# Tmux + Claude shortcuts
alias tc='tmux-claude.sh'
alias tcc='tmux-claude.sh --continue'

# Neofetch replacement with hostname-aware config
alias neofetch='~/.config/fastfetch/select-config.sh'
alias fastfetch='~/.config/fastfetch/select-config.sh'

# Context-aware task runner: fzf picker for npm scripts or Rails tasks
# - In a directory with package.json → pick from `scripts` + run via npm
# - In a Rails app (bin/rails present) → pick from `rails -T` + run via bin/rails
# - Otherwise Rakefile → pick from `rake -T` + run via bundle exec rake
function run() {
  if ! command -v fzf &>/dev/null; then
    echo "❌ fzf is required. Install with: brew install fzf"
    return 1
  fi

  if [[ -f package.json ]]; then
    if ! command -v jq &>/dev/null; then
      echo "❌ jq is required. Install with: brew install jq"
      return 1
    fi
    local script
    script=$(jq -r '.scripts // {} | to_entries[] | "\(.key)\t\(.value)"' package.json \
      | column -t -s $'\t' \
      | fzf --prompt="  npm run > " --height=50% --reverse --ansi \
            --preview='echo {} | sed -E "s/^[^[:space:]]+[[:space:]]+//"' \
            --preview-window=down:3:wrap \
      | awk '{print $1}')
    [[ -z "$script" ]] && return 0
    echo "▶ npm run $script"
    npm run "$script"

  elif [[ -x bin/rails ]]; then
    local task
    task=$(bin/rails -T 2>/dev/null \
      | fzf --prompt="  rails > " --height=50% --reverse --ansi \
      | awk '{print $2}')
    [[ -z "$task" ]] && return 0
    echo "▶ bin/rails $task"
    bin/rails "$task"

  elif [[ -f Rakefile ]]; then
    local task
    task=$(bundle exec rake -T 2>/dev/null \
      | fzf --prompt="  rake > " --height=50% --reverse --ansi \
      | awk '{print $2}')
    [[ -z "$task" ]] && return 0
    echo "▶ bundle exec rake $task"
    bundle exec rake "$task"

  else
    echo "❌ No package.json, bin/rails, or Rakefile found in $PWD"
    return 1
  fi
}
