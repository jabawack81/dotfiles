# Testing the quickshell greeter

The loop is three commands; `scripts/greeter.sh` is behind them.

    make greeter-deploy   # install to /etc/greetd, verify byte-for-byte, restart greetd
    # Ctrl+Alt+F1, log in, then Ctrl+Alt+F2 if it failed
    make greeter-logs     # breadcrumbs, the session's own output, greetd's view

`greeter-deploy` refuses to restart greetd unless the deployed files match
the repo and the `greeter` user can read them, and it truncates the
session log first, so a stale deploy or a stale log cannot pass for a
fresh result. Both did, once each.

## How greetd runs the session

greetd does not exec the command the greeter sends. It joins the list
with spaces and runs `exec <joined>` through `/bin/sh -c`
(`greetd/src/session/worker.rs`). `source_profile` only prepends the
profile sourcing; the join happens either way. So the command must be
valid as a shell command line, which is why the greeter sends one
shell-quoted element. Sending an argv array such as
`["sh", "-c", "env BAR=caelestia /usr/bin/start-hyprland"]` is re-split
into `sh -c env` plus stray positional arguments: the session was a bare
`env` printing the environment and exiting, which looked exactly like a
compositor crashing on startup.

## What a spare-VT greetd can and cannot show

    sudo greetd --config /etc/greetd/test.toml

runs a second greetd on vt 3 (Ctrl+Alt+F3; Ctrl+Alt+F1 returns). It
proves the greeter draws and that the password is accepted or rejected.
Whether a second Hyprland for the same user can come up on vt 3 is
untested; the uwsm-managed entry certainly cannot, since uwsm refuses
outside vt 1 and outside a login shell (`uwsm check may-start -v`). A
session that bounces straight back on vt 3 is therefore not evidence
either way about the greeter -- log in on vt 1 for that.

## Where the evidence is

- `journalctl -t greetd-session` -- the session's stdout and stderr,
  which the greeter routes through systemd-cat. Hyprland's startup banner
  and its first log lines land here instead of on tty1.
- `journalctl -b | grep greetd` -- `session opened`/`session closed` for
  the user show how long the session lived. Same second means it exited
  immediately.
- A session that is still open with a blank screen: `loginctl
  list-sessions`, then read `/proc/<leader-child>/cmdline`. A stuck
  process with an inspectable argv is worth more than any theory.

## Getting out

Ctrl+Alt+F2 reaches a TTY whatever the greeter does. regreet stays
installed as the fallback: swap the commented `command` lines in
`/etc/greetd/config.toml` and `sudo systemctl restart greetd`. To drop
greetd entirely: `sudo systemctl disable --now greetd && sudo systemctl
enable --now sddm`.
