#!/bin/bash

# Definir nomes da VM e do container
vm_gpu="nome_da_vm"
docker_gpu="nome_do_container"

# Verificar se a GPU está disponível
gpu_available=$(nvidia-smi --query-gpu=memory.used --format='csv' | tail -n 1)

while [ "$gpu_available" = "0" ]; do
  # Reiniciar o container e aguardar até que ele esteja desligado
  systemctl start $docker_gpu &> /dev/null
  
  while [ $? -eq 0 ]; do
    sleep 1
    if [ $(systemctl is-active --quiet $docker_gpu) = "active" ]; then
      echo "Container em execução, aguardando a VM"
      sleep 10
    else
      break
    fi
  done
  
  # Iniciar a VM quando o container estiver desligado
  virsh start $vm_gpu
  
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