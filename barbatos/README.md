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

## System side

Everything that touches `/etc` is in `tasks/barbatos.yml`: NVIDIA 580xx via
AUR (nvidia-open does not support Maxwell), EnvyControl mode (`barbatos_gpu_mode`:
`hybrid` keeps prime-run, `integrated` powers the dGPU off — Maxwell has no RTD3),
fingerprint (python-validity + open-fprintd + PAM), ThinkPad fan control,
iwd MAC randomisation, sysctl/udev knobs, services and groups.

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
