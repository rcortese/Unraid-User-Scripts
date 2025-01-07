#!/bin/bash
set -e

# User filled variables
readonly VM_NAMES=( "HiveOS" "Win11" )
readonly GRACEFUL_SHUTDOWN_TIMEOUT=30
readonly FORCED_SHUTDOWN_TIMEOUT=10
readonly FORCE_SHUTDOWN_IF_TIMEOUT=true

# Functions

# Returns true (0) if vm is listed as active
# $1 - name of vm to search for
is_vm_active() {

  local vm_name="$1"

  virsh list | grep -q "$vm_name"
}

# Requests graceful shutdown of vm.
# $1 - name of vm to shutdown
shutdown_vm() {

  local vm_name="$1"

  virsh shutdown "$vm_name"
}

# Forcefully shuts down vm.
# $1 - name of vm to shutdown
force_shutdown_vm() {

  local vm_name="$1"

  virsh destroy "$vm_name"
}

# Starts vm passed as argument
# $1 - name of vm to start
start_vm() {

  local vm_name="$1"

  virsh start "$vm_name"
}

# Halts execution until vm is no longer listed or (optional) timeout is exceeded
# $1 - name of vm to await for shutdown
# $2 - timeout (in seconds)
# $3 - termination type (for logging only) - optional
await_vm_termination() {
  local vm_name="$1"; shift
  local timeout=$1; shift
  local termination_type="$1"

  local time_elapsed=0
  until ! is_vm_active "$vm_name"
  do
    local timeout_warning="timeout in $((timeout-time_elapsed))s"
    echo "Waiting for $termination_type shutdown of $vm_name ($timeout_warning)"
    sleep 1 && ((time_elapsed++))
    if [ $time_elapsed -gt $timeout ]; then
      echo "Timeout reached!"
      break
    fi
  done
}

# Alternates between two vms
# $1 - name of vm to shutdown
# $2 - name of vm to start
alternate_vms() {

  local vm_to_shutdown="$1"; shift
  local vm_to_start="$1"

  if is_vm_active "$vm_to_shutdown"; then
    shutdown_vm "$vm_to_shutdown"
    await_vm_termination "$vm_to_shutdown" $GRACEFUL_SHUTDOWN_TIMEOUT "graceful"

    if is_vm_active "$vm_to_shutdown"; then
      if $FORCE_SHUTDOWN_IF_TIMEOUT; then
        force_shutdown_vm "$vm_to_shutdown"
        await_vm_termination "$vm_to_shutdown" $FORCED_SHUTDOWN_TIMEOUT "forced"
      fi
    fi
  fi

  start_vm "$vm_to_start"
}

# Main function...
# The magic starts here
main() {

  local vm_to_start="${VM_NAMES[0]}"
  local vm_to_shutdown

  for i in "${!VM_NAMES[@]}"
  do
    if is_vm_active "${VM_NAMES[i]}"; then
      vm_to_shutdown="${VM_NAMES[i]}"
      vm_to_start="${VM_NAMES[i+1]:-${VM_NAMES[0]}}"
      break
    fi
  done

  alternate_vms "$vm_to_shutdown" "$vm_to_start"

  sleep 10
  if ! is_vm_active "$vm_to_start"; then
    start_vm "$vm_to_shutdown"
    echo "ERROR: VM $vm_to_start seems to not have been started!"
    exit 1
  else
    echo "SUCCESS: VM $vm_to_start seems to have been started successfully!"
    exit 0
  fi
}

main

