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

  if virsh list | grep -q "$vm_name"; then
    return 0
  else
    return 1
  fi
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
# The magic starts here
main() {
  local time_elapsed=0

  until (( time_elapsed > TIMEOUT )); do
    if is_vm_active "$VM_NAME"; then
      echo "$VM_NAME active! Binding devices..."

      for device in "${DEVICES_LIST[@]}"; do
        echo "Binding $device to $VM_NAME"
        bind_device "id" "id"
      done

      break
    else
      echo "$VM_NAME not active yet..."
      sleep 1
      ((time_elapsed++))
    fi
  done

  if ! is_vm_active "$VM_NAME"; then
    echo "Error: $VM_NAME not active!"
    exit 1
  else
    echo "Success: script has tried to bind the following devices to $VM_NAME:"
    for device in "${DEVICES_LIST[@]}"; do
      echo "  - $device"
    done
    exit 0
  fi
}

main

