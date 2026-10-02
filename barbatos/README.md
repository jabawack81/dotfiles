# Barbatos Config

Lenovo ThinkPad T470p — Intel HD 630 + NVIDIA GeForce 940MX (Maxwell),
Validity fingerprint reader, vanilla Arch + Hyprland (formerly `lupus` on
Omarchy; the runbook for the reinstall lives in the personal vault under
`500 - Hardware/`).

## What's here

- `hypr/hyprland.lua` — panel + dock monitors (DP-4/DP-5 forced to 1080p60),
  US keyboard with compose on Caps, lid switch binds, floating rules for the
  GPU/fan TUIs.
- `hypr/lid.sh` — lid handler: panel off + fingerprint daemon stopped when
  closed, both back when opened; `init` applies the current state at startup.
- `hypr/nvidia-suspend-fix.sh` — installed to
  `/usr/lib/systemd/system-sleep/nvidia-gpu-toggle` by the playbook. Removes
  the 940MX from the PCI bus before sleep and rescans after; the 580xx legacy
  driver otherwise freezes on resume.
- `waybar/config-machine.jsonc` — kyrios layout plus `custom/gpu`
  (EnvyControl mode + temp) and `custom/fan` (thinkpad_acpi RPM).

## Greeter

greetd rather than sddm, whose unthemed default looks nothing like the
desktop behind it. `greetd/greeter/shell.qml` is a self-contained
quickshell greeter on the same Nord palette as the bar; it shares no code
with the shell, because the `greeter` user cannot read a home directory at
0700. The playbook copies `barbatos/greetd/` to `/etc/greetd`, and seeds
the greeter wallpaper from `~/Pictures/wallpapers/wall0.png` so greeter and
desktop show the same image.

regreet stays installed as the fallback: swap the commented command in
`/etc/greetd/config.toml` and restart greetd. To go back to sddm entirely:
`sudo systemctl disable --now greetd && sudo systemctl enable --now sddm`.
A TTY on Ctrl+Alt+F2 stays available either way.

Testing changes to the greeter: `make greeter-deploy`, log in, `make
greeter-logs`; `barbatos/greetd/TESTING.md` has the detail. The one thing
to know about greetd is that it joins the session command into a string
and runs it through `sh -c`, so the greeter sends a single quoted element.

## System side

Everything that touches `/etc` is in `tasks/barbatos.yml`: NVIDIA 580xx via
AUR (nvidia-open does not support Maxwell), EnvyControl mode (`barbatos_gpu_mode`:
`hybrid` keeps prime-run, `integrated` powers the dGPU off — Maxwell has no RTD3),
fingerprint (python-validity + open-fprintd + PAM), ThinkPad fan control,
iwd MAC randomisation, sysctl/udev knobs, services and groups, and the boot
presentation: `barbatos_quiet_boot` is appended to `/etc/kernel/cmdline` and
baked into the UKI, and systemd-boot's menu is hidden (hold Space at boot
to see it) with its text sized for the panel.

## After the first `make setup`

1. Reboot so the 580xx driver and EnvyControl take effect.
2. `envycontrol --query` → the configured mode; in `hybrid`: `nvidia-smi` and `prime-run glxinfo | grep renderer` → 940MX.
3. `fprintd-verify` (a finger is likely still enrolled on the sensor; `fprintd-enroll` otherwise). hyprlock/sddm/polkit use it; set `barbatos_fingerprint_sudo: true` to add sudo/su.
4. `sudo tailscale up`.
5. `systemctl suspend` a few times; `journalctl -b -p err | grep -i nvidia` should be empty.

## Raspberry Pi Pico / PicoRuby

- Hold BOOTSEL while plugging in → the Pico appears as a USB drive (`RPI-RP2`),
  auto-mounted by thunar (gvfs + thunar-volman + udisks2). Drop the `.uf2` on
  it, or `picotool load -x firmware.uf2`.
- After it reboots into the firmware it's a USB serial device, `/dev/ttyACM0`
  (PlatformIO udev rules, `uucp` group — no sudo):
  `picocom -b 115200 /dev/ttyACM0` (quit: `Ctrl-A Ctrl-X`) or
  `screen /dev/ttyACM0 115200`.
- `picotool info -a` shows what's flashed; `lsusb | grep 2e8a` confirms the
  board is seen at all.
