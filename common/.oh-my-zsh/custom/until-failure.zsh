# until-failure.zsh — run a command in a loop until it fails, or until
# MAX_RUNS successes. Useful for hunting flaky tests:
#   until_failure -r 50 -n npm test
#
# -r NUM    max runs (default 10)
# -m MSG    notification message (default 'Max runs reached')
# -n        send a ntfy.sh notification when done (needs $NTFY_TOPIC)
# -h        help
#
# Optional: ntfy.sh push (set $NTFY_TOPIC, use -n). No other dependencies.
# Install: source this from ~/.zshrc (or drop in ~/.oh-my-zsh/custom/).

# Internal: post a ntfy.sh notification, silently no-op if disabled or
# $NTFY_TOPIC is unset.
_until_failure_notify() {
  local enabled=$1 message=$2
  [[ "$enabled" != true || -z "$NTFY_TOPIC" ]] && return 0
  curl -sS -d "$message" "ntfy.sh/$NTFY_TOPIC" >/dev/null
}

function until_failure {
  local MAX_RUNS=10
  local NOTIFY=false
  local MESSAGE="Max runs reached"
  local HELP=false
  local start_time=$(date +%s)

  while getopts "m:r:nh" opt; do
    case $opt in
      m) MESSAGE=$OPTARG ;;
      r) MAX_RUNS=$OPTARG ;;
      n) NOTIFY=true ;;
      h) HELP=true ;;
    esac
  done
  shift $((OPTIND - 1))

  if [[ "$HELP" == true || $# -eq 0 ]]; then
    cat <<HELP_EOF
Usage: until_failure [-r runs] [-m message] [-n] command [args...]
  -r NUM    Maximum number of runs (default: 10)
  -m MSG    Notification message (default: 'Max runs reached')
  -n        Send notification via ntfy.sh when done (needs \$NTFY_TOPIC)
  -h        Show this help message

Example: until_failure -r 50 -n -m 'Tests finally failed!' npm test
HELP_EOF
    return 0
  fi

  if [[ "$NOTIFY" == true && -z "$NTFY_TOPIC" ]]; then
    echo "Warning: -n set but \$NTFY_TOPIC is empty; notifications will be dropped"
  fi

  local divider="############################################################################################"
  echo "$divider"

  local i=0
  local exit_code=0
  while (( i < MAX_RUNS )); do
    "$@"
    exit_code=$?
    if (( exit_code != 0 )); then
      local elapsed=$(( $(date +%s) - start_time ))
      echo "Command failed with exit code: $exit_code"
      echo "Failed after $((i + 1)) runs in $elapsed seconds"
      _until_failure_notify "$NOTIFY" "Command failed after $((i + 1)) runs (exit: $exit_code)"
      return $exit_code
    fi
    (( i++ ))
    echo "Run number: $i/$MAX_RUNS - Success"
    echo "$divider"
  done

  local elapsed=$(( $(date +%s) - start_time ))
  echo "Max runs reached - command succeeded $MAX_RUNS times in $elapsed seconds"
  _until_failure_notify "$NOTIFY" "${MESSAGE} - succeeded $MAX_RUNS times"
}
