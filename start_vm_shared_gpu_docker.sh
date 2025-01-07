#!/bin/bash

# Definir nomes da VM e do container
VM_NAME="nome_da_vm"
CONTAINER_NAME="nome_do_container"

is_vm_running() { [ "$(virsh list --state-running | grep -c "$VM_NAME")" -eq 1 ]; }

is_container_running() { [ "$(docker inspect --format '{{ .State.Running }}' "$CONTAINER_NAME" 2> /dev/null)" = "true" ]; }

main() {

  # Parar o container
  docker stop $CONTAINER_NAME

  # Aguardar até que o container seja desligado
  while is_container_running; do
    echo "Waiting for container to be stopped..."
    sleep 1
  done

  virsh start $VM_NAME
  sleep 30

  while is_vm_running; do
    sleep 60
  done
  
  # Reiniciar o container
  docker start $CONTAINER_NAME
}

main
