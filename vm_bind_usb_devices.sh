#!/bin/bash
set -e

###################################################
## Variables
##

# VM name as listed by virsh (same as on Unraid VM tab)
readonly VM_NAME="Windows 10"

# List of devices to bind
readonly -a DEVICES_LIST=("Logitech mouse" "K78 Keyboard")

# Timeout
readonly TIMEOUT=60

###################################################
## Functions

# Returns true (0) if VM is listed as active
# $1 - name of VM to search for
is_vm_active() {
  local vm_name="$1"

  virsh list --name | grep -q "^$vm_name$"
}

# Bind device to VM
# $1 - device idVendor
# $2 - device idProduct
bind_device() {
  local idVendor="$1"
  local idProduct="$1"

  # TODO:
  # virsh attach-device $vm_name --file usb_device.xml --current
}

# Main function...
main() {
  local vm_active=0
  local time_elapsed=0

  # Wait for VM to be active
  while (( time_elapsed <= TIMEOUT )); do
    if is_vm_active "$VM_NAME"; then
      vm_active=1
      break
    else
      ((time_elapsed++))
      sleep 1
    fi
  done

  if (( vm_active == 0 )); then
    echo "Error: $VM_NAME not active after $TIMEOUT seconds." >&2
    exit 1
  fi

  for device in "${DEVICES_LIST[@]}"; do
    echo "Binding $device to $VM_NAME"
    # TODO: remove hardcoded values + implement bind_device
    bind_device "id" "id"
  done
}

main

