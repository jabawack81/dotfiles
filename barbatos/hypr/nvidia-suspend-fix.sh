#!/bin/bash
# Systemd system-sleep hook for ThinkPad T470p (NVIDIA 940MX, 580xx driver)
#
# The legacy 580xx driver fails to properly suspend/resume the discrete GPU,
# causing the system to freeze on wake. This script works around it by:
#   - Pre-suspend: removing the NVIDIA GPU from the PCI bus entirely
#   - Post-resume: rescanning PCI to bring it back
#
# Installed to /usr/lib/systemd/system-sleep/nvidia-gpu-toggle

NVIDIA_PCI="0000:02:00.0"
NVIDIA_REMOVE="/sys/bus/pci/devices/$NVIDIA_PCI/remove"
PCI_RESCAN="/sys/bus/pci/rescan"

case "$1" in
    pre)
        # Stop processes using the GPU before removing it
        systemctl stop nvidia-persistenced.service 2>/dev/null || true

        # Unload NVIDIA kernel modules (order matters: drm → modeset → uvm → nvidia)
        modprobe -r nvidia_drm 2>/dev/null || true
        modprobe -r nvidia_modeset 2>/dev/null || true
        modprobe -r nvidia_uvm 2>/dev/null || true
        modprobe -r nvidia 2>/dev/null || true

        # Remove the GPU from PCI bus
        if [ -w "$NVIDIA_REMOVE" ]; then
            echo 1 > "$NVIDIA_REMOVE"
        fi
        ;;
    post)
        # Rescan PCI bus to re-discover the GPU
        if [ -w "$PCI_RESCAN" ]; then
            echo 1 > "$PCI_RESCAN"
        fi

        # Wait for the device to settle
        sleep 1

        # Reload NVIDIA modules
        modprobe nvidia 2>/dev/null || true
        modprobe nvidia_modeset 2>/dev/null || true
        modprobe nvidia_drm 2>/dev/null || true
        modprobe nvidia_uvm 2>/dev/null || true

        # Restart persistence daemon
        systemctl start nvidia-persistenced.service 2>/dev/null || true
        ;;
esac
