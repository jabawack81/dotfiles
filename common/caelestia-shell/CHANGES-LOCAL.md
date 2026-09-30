# Local changes to the vendored caelestia shell

Everything here is ours, not upstream. `make caelestia-update` preserves
files whose names contain `Custom` and this file; anything else listed
below lives in an upstream file and **must be re-applied by hand after an
update**.

## Preserved automatically

- `modules/bar/components/CustomStatus.qml` — a bar entry driven by one of
  the dotfiles status scripts. The scripts emit waybar's JSON, so the
  waybar bars and this one cannot disagree about what they report.

## Re-apply after every update

- `modules/bar/Bar.qml` — four `DelegateChoice` blocks at the end of the
  `DelegateChooser`, registering the `gpu`, `fan`, `caffeine` and
  `bedtime` entry ids against `CustomStatus`. Entry ids are free-form
  strings in the config, so nothing else needs changing.

The entries themselves are turned on in `common/caelestia/shell.json`.
Listing `bar.entries` replaces the default list outright, so that file
enumerates the upstream entries too; check it against upstream's defaults
after an update in case new ones were added.
