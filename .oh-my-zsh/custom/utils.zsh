
function until_failure {

  MAX_RUNS=10
  NOTIFY=false
  MESSAGE="Max runs reached"

  while getopts "m:r:n" opt; do
    case ${opt} in
      m) MESSAGE=$OPTARG;;
      r) MAX_RUNS=$OPTARG;;
      n) NOTIFY=true;;
    esac
  done
  shift $((OPTIND -1))


  i=0;
  echo "############################################################################################"

  while "$@"; do
    echo "Run number: $((i+1))/$MAX_RUNS"
    echo "############################################################################################"
    let i=$i+1
    if [ $i -eq $MAX_RUNS ]; then
      echo "Max runs reached"
      if [ "$NOTIFY" = true ]; then
        curl -sS -d ${MESSAGE} ntfy.sh/$NTFY_TOPIC >> /dev/null
      fi
      break
    fi

  done
}
