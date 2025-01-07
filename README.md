# Unraid Scripts

A personal collection of scripts for Unraid Server. These scripts can be executed via SSH, console, or through the User Scripts plugin.

(Currently tested on Unraid v7.0.0-rc.2)

## [vm_cycle.sh](vm_cycle.sh)

Designed for resource-sharing VMs (such as gaming/mining VMs sharing the same GPU), this script cycles through a list shutting down one VM and starting the next.

* The user must set `VM_NAMES` and 3 other configuration variables upon import.

```sh
# Example: populate VM_NAMES_LIST with your setup
declare -r -a VM_NAMES_LIST=("Pop_OS" "Windows10" "HiveOS")
```

The script functions as follows (using `virsh`):

* Searches for an active VM within the list.
* If an active VM is found:
  * Shuts it down.
  * Periodically checks until it is no longer active (or timeout occurs).
* Starts the next VM in the list.
* If startup is unsuccessful:
  * Restarts the originally active VM.

If executed from within a VM on the list, run it in the background to prevent script termination upon VM shutdown.

Inspired by [a tutorial video by SpaceInvader One](https://www.youtube.com/watch?v=QoVJ0460cro).


## [vm_bind_usb_devices.sh](vm_bind_usb_devices.sh)

Binds USB devices to a VM until successful (or timeout occurs).

Created to address the issue of permanently binding USB devices to a VM, which requires these devices to be connected at startup. This script resolves issues with KVM switches and other devices by binding devices on each VM startup, ensuring proper VM startup while being slightly less convenient.

## [vm_start_shared_gpu.sh](vm_start_shared_gpu.sh)

Intended for use when passing the same GPU to both a VM and a Docker container.

This script automatically starts the VM in a detached screen session and then stops the container, allowing the VM to utilize the GPU. Once the VM is stopped, the container is automatically started again. This allows for seamless sharing of a single GPU between VMs and Docker containers alternating resource reservation.

* The user must set `VM_NAME` and `CONTAINER_NAME` variables upon import.

