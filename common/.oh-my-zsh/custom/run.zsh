# run.zsh — context-aware task runner: fzf picker for the current project.
#   package.json → pick from `scripts` + run via `npm`
#   bin/rails    → pick from `bin/rails -T` + run via `bin/rails`
#   Rakefile     → pick from `rake -T` + run via `bundle exec rake`
# Usage: `run` in a project dir, pick a task, Enter. Requires fzf.
# Rake tasks that declare arguments (e.g. `task:name[arg1,arg2]`) get a
# per-argument prompt — leave any value empty to skip it.
# Install: source this from ~/.zshrc (or drop in ~/.oh-my-zsh/custom/).

# Internal: run a producer, fzf-pick from its output, then exec a command.
#
# The producer is invoked *inside* this helper via $(...) rather than piped
# into it from outside. The piped-from-outside form (producer | helper) leaves
# fzf reading from the long-lived outer pipe, which can confuse fzf's TTY
# setup in some terminals and fail with "Input/output error". Keeping the
# producer pipe self-contained inside $(...) sidesteps it.
#
# $1   fzf prompt label
# $2   awk field to extract from the picked row
# $3   producer function name (called with no args; stdout is the task list)
# $4.. command to run with the picked task appended
_run_pick_and_exec() {
  local prompt=$1 field=$2 producer=$3
  shift 3
  local task
  task=$("$producer" 2>/dev/null \
         | fzf --prompt="  $prompt > " --height=50% --reverse --ansi \
         | awk -v f="$field" '{print $f}')
  [[ -z "$task" ]] && return 0

  # Rake declares argument names in [brackets], e.g.
  # `manual_tasks:delete_complaint_note[complaint_note_id,execute]`.
  # Without prompting, those names get passed as VALUES (running with the
  # literal string "complaint_note_id"). Prompt for each one instead and
  # rebuild the invocation.
  if [[ "$task" == *\[*\]* ]]; then
    local base="${task%%\[*}"
    local arg_spec="${task#*\[}"
    arg_spec="${arg_spec%\]}"

    echo "Task takes arguments — press Enter to skip any:"
    local -a values
    local arg val
    for arg in ${(s:,:)arg_spec}; do
      printf "  %s: " "$arg"
      read -r val
      values+=( "$val" )
    done

    # Drop trailing empties: Rake treats `task[a,]` and `task[a]` the same
    # for missing trailing args. Interior empties (`task[a,,c]`) are kept
    # because position matters there.
    while (( ${#values[@]} > 0 )) && [[ -z "${values[${#values[@]}]}" ]]; do
      values=( "${values[@]:0:$((${#values[@]}-1))}" )
    done

    if (( ${#values[@]} > 0 )); then
      task="${base}[${(j:,:)values}]"
    else
      task="$base"
    fi
  fi

  echo "▶ $* $task"
  # Single-quote the task name so [brackets] don't glob-expand on Up+Enter.
  print -s "$* '$task'"
  "$@" "$task"
}

# Task list producers. Defined as functions so _run_pick_and_exec can call
# them by name without going through a pipe.
_run_rails_tasks() { bin/rails -T; }
_run_rake_tasks()  { bundle exec rake -T; }

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
    print -s "npm run '$script'"
    npm run "$script"

  elif [[ -x bin/rails ]]; then
    _run_pick_and_exec "rails" 2 _run_rails_tasks bin/rails

  elif [[ -f Rakefile ]]; then
    _run_pick_and_exec "rake" 2 _run_rake_tasks bundle exec rake

  else
    echo "❌ No package.json, bin/rails, or Rakefile found in $PWD"
    return 1
  fi
}
