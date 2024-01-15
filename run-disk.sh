#!/usr/bin/env bash

DISK_PATH=$1
BIOS_PATH="/usr/share/ovmf/x64/OVMF.fd"
IOMMU_GPU_GROUP_ID="0c:00.0"


# Simply prints this script's usage.
function usage () {
  echo "Usage: $0 [DEVICE]"
}

if [[ "$DISK_PATH" = "" ]] || [[ ! -e $DISK_PATH ]]; then
  echo "Disk path '$DISK_PATH' not found"
  usage
  exit 1
fi

# Q35 Machines refers to the Q35 chipset, which is a VM Platform which emulates
# modern hardware and can use UEFI firmware instead of BIOS.
#
# SMP stands for Symmetric Multiprocessing. Essentially Virtual CPU cores.
#
# -cpu host indicates to qemu to use the best emulation compatibility for the host's CPU.

# In order argument description:
#   - Enable KVM virtualization.
#   - Mount raw device.
#   - Mount BIOS image.
#   - Enable boot menu.
#   - Allocate 8GiB of mem to VM.
#   - Specify the machine time and KVM acceleration.
#   - Specify 6 vcores.
#   - Use the host CPU model.
#   - Set keyboard layout to US.
#   - Use VNC display :5901
#   - Specify the BIOS image.
#   - Configure a network interface.
#   - Port forward host:5555 <-> guest:22.
qemu-system-x86_64 \
  -enable-kvm \
  -drive file="$DISK_PATH",format=raw \
  -drive if=pflash,format=raw,readonly=on,file="$BIOS_PATH" \
  -boot menu=on \
  -m 8G \
  -machine type=q35,accel=kvm \
  -smp 6 \
  -cpu host \
  -k en-us \
  -display vnc=:1 \
  -bios "$BIOS_PATH" \
  -net nic \
  -net user,hostfwd=tcp::5555-:22,hostname=guestOS

# Removed options.
#   - Use virtio for VGA.
#   - Forward serial output to stdio.
#   - Passthrough host GPU device to VM. multifunction exposes all GPU functions to the VM.
#   - Disable virtualized graphics.
  #-vga virtio \
  #-serial stdio \
  #-device vfio-pci,host=$IOMMU_GPU_GROUP_ID,bus=pcie.0
  #-nographic
