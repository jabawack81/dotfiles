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
  
  # Parse options
  shift
  while getopts "k:h" opt; do
    case ${opt} in
    k) keep_latest=$OPTARG ;;
    h) HELP=true ;;
    esac
  done
  
  if [ "$HELP" = true ] || [ -z "$manager" ]; then
    echo "Usage: clean_version_manager MANAGER [-k NUM]"
    echo "  MANAGER   Version manager (rbenv, nodenv, etc.)"
    echo "  -k NUM    Keep the latest NUM versions"
    echo "  -h        Show this help message"
    echo ""
    echo "Example: clean_version_manager rbenv -k 2"
    return 0
  fi
  
  # Check if manager exists
  if ! command -v $manager &> /dev/null; then
    echo "Error: $manager not found"
    return 1
  fi
  
  local versions=($($manager versions --bare | sort -V))
  local total=${#versions[@]}
  
  if [ $keep_latest -gt 0 ] && [ $keep_latest -lt $total ]; then
    echo "Keeping the latest $keep_latest versions"
    versions=("${versions[@]:0:$((total - keep_latest))}")
  fi
  
  for ver in "${versions[@]}"; do
    echo -e "\nVersion: $ver"
    
    # Try to find projects using this version
    local usage_info=""
    if [ "$manager" = "rbenv" ]; then
      usage_info=$(find ~ -name ".ruby-version" -type f 2>/dev/null | xargs grep -l "^$ver$" 2>/dev/null | head -5)
    elif [ "$manager" = "nodenv" ]; then
      usage_info=$(find ~ -name ".node-version" -type f 2>/dev/null | xargs grep -l "^$ver$" 2>/dev/null | head -5)
    fi
    
    if [ -n "$usage_info" ]; then
      echo "  Used in:"
      echo "$usage_info" | sed 's/^/    /'
    else
      echo "  Not found in any projects"
    fi
    
    printf "Uninstall? [y/N]: "
    read -r uninstall
    if [[ "$uninstall" =~ ^[yY] ]]; then
      $manager uninstall -f $ver
      echo "  Uninstalled $ver"
    else
      echo "  Keeping $ver"
    fi
  done
}

# Convenience aliases
alias clean_rbenv='clean_version_manager rbenv'
alias clean_nodenv='clean_version_manager nodenv'

# Tmux + Claude shortcuts
alias tc='tmux-claude.sh'
alias tcc='tmux-claude.sh --continue'

# Neofetch replacement with hostname-aware config
alias neofetch='~/.config/fastfetch/select-config.sh'
alias fastfetch='~/.config/fastfetch/select-config.sh'
