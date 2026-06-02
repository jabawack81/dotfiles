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
