# Testing the quickshell greeter without risking your login

The greeter's drawing can be checked from inside a session:

    qs -p ~/dotfiles/barbatos/greetd/greeter

but authentication cannot — there is no greetd socket to talk to, so
`Greetd.available` is false and the password field does nothing. The part
that can actually lock you out is the launch call, and that needs a real
greetd.

Run one on a spare VT, with its own socket, leaving the display manager
alone:

    sudo greetd --config /etc/greetd/test.toml

`test.toml` (installed by the playbook alongside the real config) runs on
vt 3, so switch to it with Ctrl+Alt+F3 and log in there. Your desktop on
vt 1 is untouched, and Ctrl+Alt+F1 returns to it.

What to check:

1. The password is accepted and a wrong one shows an error.
2. The session actually starts — this is the step most likely to fail, as
   it depends on what `Greetd.launch` expects. If the greeter authenticates
   and then sits there or exits, the Exec line from the desktop entry is
   being passed in the wrong shape.
3. Clicking the session name cycles through the entries in
   /usr/share/wayland-sessions.

Only once that passes is it worth pointing the real greeter at it, by
changing `command` in /etc/greetd/config.toml from `regreet` to
`qs -p /etc/greetd/greeter`.

Back out at any time:

    sudo systemctl disable --now greetd && sudo systemctl enable --now sddm
