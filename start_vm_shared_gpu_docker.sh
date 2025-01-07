#!/bin/bash

# Definir nomes da VM e do container
VM_NAME="nome_da_vm"
CONTAINER_NAME="nome_do_container"

# Verificar se a GPU está disponível
gpu_available=$(nvidia-smi --query-gpu=memory.used --format='csv' | tail -n 1)

while [ "$gpu_available" = "0" ]; do

  docker stop $CONTAINER_NAME
  
  while [ "$(docker inspect --format '{{ .State.Running }}' "$CONTAINER_NAME" 2> /dev/null)" = "true" ]; do
    sleep 1
  done
  
  # Iniciar a VM quando o container estiver desligado
  virsh start $VM_NAME
  
  # Aguardar até que a VM esteja rodando corretamente
  sleep 30
  
  # Verificar se a GPU está disponível novamente após a VM estar em execução
  gpu_available=$(nvidia-smi --query-gpu=memory.used --format='csv' | tail -n 1)
  
  if [ "$gpu_available" = "0" ]; then
    echo "GPU não está disponível"
  else
    echo "VM e container estão funcionando corretamente"
  fi
  
  # Aguardar até que a VM esteja rodando corretamente antes de reiniciar o container
  sleep 30
done

# Escrever os resultados para um arquivo de log
echo "$(date) - GPU disponível: $gpu_available" >> /var/log/gpu-vm.log