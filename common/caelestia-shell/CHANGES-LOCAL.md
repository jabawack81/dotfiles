# Local changes to the vendored caelestia shell

Everything here is ours, not upstream. `make caelestia-update` preserves
files whose names contain `Custom` and this file; anything else listed
below lives in an upstream file and **must be re-applied by hand after an
update**.

## Preserved automatically

- `modules/bar/components/CustomStatus.qml` — a bar entry driven by one of
  the dotfiles status scripts. The scripts emit waybar's JSON, so the
  waybar bars and this one cannot disagree about what they report.
- `modules/bar/popouts/CustomCaffeine.qml` — the power-state picker shown
  when the caffeine entry is hovered. It reads the current state from the
  file caffeine-toggle.sh writes and shells out to the same script to
  change it.

## Re-apply after every update

- `modules/bar/Bar.qml` — two hunks: four `DelegateChoice` blocks at the
  end of the `DelegateChooser` registering the `gpu`, `fan`, `caffeine`
  and `bedtime` entry ids against `CustomStatus`, and a `caffeine` branch
  in `handleHover` that opens the picker. Entry ids are free-form strings
  in the config, so nothing else needs changing.
- `modules/bar/popouts/Content.qml` — a `Popout` registering the
  `caffeine` name against `CustomCaffeine`.

The entries themselves are turned on in `common/caelestia/shell.json`.
Listing `bar.entries` replaces the default list outright, so that file
enumerates the upstream entries too; check it against upstream's defaults
after an update in case new ones were added.
