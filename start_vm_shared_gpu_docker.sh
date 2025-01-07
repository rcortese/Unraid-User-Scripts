#!/bin/bash

# Definir nomes da VM e do container
VM_NAME="nome_da_vm"
CONTAINER_NAME="nome_do_container"

is_gpu_unused() {
  local result=$(nvidia-smi --query-gpu=memory.used --format=csv,noheader,nounits)
  [ "$result" = "0" ]
}

is_container_running() {
  local container_status
  container_status=$(docker inspect --format '{{ .State.Running }}' "$CONTAINER_NAME" 2> /dev/null)
  [ "$container_status" = "true" ]
}

main() {

  # Parar o container
  docker stop $CONTAINER_NAME

  # Aguardar até que o container seja desligado
  while is_container_running; do
    sleep 1
  done

  # Iniciar a VM e aguardar até que ela esteja rodando
  virsh start $VM_NAME
  sleep 30

  while ! is_gpu_unused; do
    
    echo "GPU em uso"
    # aguardar até proxima verificacao
    sleep 60
  done
  
  # Reiniciar o container
  docker start $CONTAINER_NAME
}

main
