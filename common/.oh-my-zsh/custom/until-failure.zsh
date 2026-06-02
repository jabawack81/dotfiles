# Run a command in a loop until it fails, or until MAX_RUNS successes.
# Useful for hunting flaky tests: until_failure -r 50 -n npm test
#
# -r NUM    max runs (default 10)
# -m MSG    notification message (default 'Max runs reached')
# -n        send a ntfy.sh notification when done (needs $NTFY_TOPIC)
# -h        help

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

  if [[ "$HELP" == true || $# -eq 0 ]]; then
    echo "Usage: until_failure [-r runs] [-m message] [-n] command [args...]"
    echo "  -r NUM    Maximum number of runs (default: 10)"
    echo "  -m MSG    Notification message (default: 'Max runs reached')"
    echo "  -n        Send notification via ntfy.sh when done (needs \$NTFY_TOPIC)"
    echo "  -h        Show this help message"
    echo ""
    echo "Example: until_failure -r 50 -n -m 'Tests finally failed!' npm test"
    return 0
  fi

  if [[ "$NOTIFY" == true && -z "$NTFY_TOPIC" ]]; then
    echo "Warning: -n set but \$NTFY_TOPIC is empty; notifications will be dropped"
  fi

  local i=0
  local divider="############################################################################################"
  echo "$divider"

  while "$@"; do
    exit_code=$?
    if (( exit_code != 0 )); then
      local elapsed=$(( $(date +%s) - start_time ))
      echo "Command failed with exit code: $exit_code"
      echo "Failed after $((i + 1)) runs in $elapsed seconds"
      if [[ "$NOTIFY" == true && -n "$NTFY_TOPIC" ]]; then
        curl -sS -d "Command failed after $((i + 1)) runs (exit: $exit_code)" "ntfy.sh/$NTFY_TOPIC" >/dev/null
      fi
      return $exit_code
    fi

    echo "Run number: $((i + 1))/$MAX_RUNS - Success"
    echo "$divider"
    (( i++ ))
    if (( i == MAX_RUNS )); then
      local elapsed=$(( $(date +%s) - start_time ))
      echo "Max runs reached - command succeeded $MAX_RUNS times in $elapsed seconds"
      if [[ "$NOTIFY" == true && -n "$NTFY_TOPIC" ]]; then
        curl -sS -d "${MESSAGE} - succeeded $MAX_RUNS times" "ntfy.sh/$NTFY_TOPIC" >/dev/null
      fi
      break
    fi
  done
}
