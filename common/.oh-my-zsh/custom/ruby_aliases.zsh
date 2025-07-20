for cmd in rails rubocop rspec foreman rake sidekiq; do
  alias b${cmd}="bundle exec $cmd"
done

alias hrc="heroku run 'rails console -- --noautocomplete' -a"
alias hlt="heroku logs -t -a"

alias brspecd="brspec --format documentation --no-fail-fast --order defined"

