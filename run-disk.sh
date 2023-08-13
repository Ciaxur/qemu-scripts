#!/usr/bin/env bash

DISK_PATH=$1

if [[ "$DISK_PATH" = "" ]] || [[ ! -e $DISK_PATH ]]; then
  echo "Disk path $DISK_PATH not found"
fi

# Q35 Machines refers to the Q35 chipset, which is a VM Platform which emulates
# modern hardware and can use UEFI firmware instead of BIOS.
#
# SMP stands for Symmetric Multiprocessing. Essentially Virtual CPU cores.
#
# -cpu host indicates to qemu to use the best emulation compatibility for the host's CPU.
qemu-system-x86_64 \
  -enable-kvm \
  -drive file="$DISK_PATH",format=raw \
  -m 8G \
  -machine type=q35,accel=kvm \
  -smp 6 \
  -cpu host \
  -k en-us \
  -display vnc=:1 \
  -bios /usr/share/ovmf/x64/OVMF.fd \
  -vga virtio


