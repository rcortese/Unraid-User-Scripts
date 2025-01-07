# Unraid Scripts

A personal collection of scripts for Unraid Server. These scripts can be executed via SSH, console, or through the User Scripts plugin.

(Currently tested on Unraid v7.0.0-rc.2)

## [cycle_vms.sh](cycle_vms.sh)

Cycles through a list of VMs, designed for resource-sharing VMs (such as gaming/mining VMs sharing the same GPU).

* The user must populate the `VM_NAMES_LIST` variable upon import.

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

Inspired by a [tutorial video by SpaceInvader One](https://www.youtube.com/watch?v=QoVJ0460cro).

## [bind_usb_devices_to_vm.sh](bind_usb_devices_to_vm.sh)

Binds USB devices to a VM until successful (or timeout occurs).

Created to address the issue of permanently binding USB devices to a VM, which requires these devices to be connected at startup. This script resolves issues with KVM switches and other devices by binding devices on each VM startup, ensuring proper VM startup while being slightly less convenient.

## [start_vm_shared_gpu_docker.sh](start_vm_shared_gpu_docker.sh)

Launches a VM in a detached screen session, allowing GPU sharing between VMs and Docker containers (used for mining, LLM, video transcoding, etc.).

**Intended for use when passing the GPU to both a VM and a Docker container. Not necessary if the GPU isn't shared between the VM and Docker.**

* The user must set `VM_NAME` and `DOCKER_CONTAINER_NAME` variables upon import.

