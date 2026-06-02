# Context-aware task runner: fzf picker for the current project type.
#   package.json → pick from `scripts` + run via `npm`
#   bin/rails    → pick from `bin/rails -T` + run via `bin/rails`
#   Rakefile     → pick from `rake -T` + run via `bundle exec rake`

# Internal: pipe a task list into fzf, parse the chosen column, then exec
# the supplied command with the picked task as its final argument.
# stdin     candidate list
# $1        fzf prompt label
# $2        awk field to extract from the picked row
# $3..      command to run with the picked task appended
_run_pick_and_exec() {
  local prompt=$1 field=$2
  shift 2
  local task
  task=$(fzf --prompt="  $prompt > " --height=50% --reverse --ansi \
         | awk -v f="$field" '{print $f}')
  [[ -z "$task" ]] && return 0
  echo "▶ $* $task"
  "$@" "$task"
}

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
    # npm gets a custom preview showing the script body, so it stays inline.
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
    bin/rails -T 2>/dev/null | _run_pick_and_exec "rails" 2 bin/rails

  elif [[ -f Rakefile ]]; then
    bundle exec rake -T 2>/dev/null | _run_pick_and_exec "rake" 2 bundle exec rake

  else
    echo "❌ No package.json, bin/rails, or Rakefile found in $PWD"
    return 1
  fi
}
