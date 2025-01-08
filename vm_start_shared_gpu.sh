#!/bin/bash

# Definir nomes da VM e do container
VM_NAME="Win11"
CONTAINER_NAME="ollama"
COMPOSE_FILE_PATH="/mnt/user/appdata/llm-stack/docker-compose.yaml" # Opcional: Usa docker-compose caso definido
ENV_FILE_PATH="/mnt/user/appdata/llm-stack/cpu-only.env" # Opcional: Reinicia o container com o env file fornecido enquanto a VM estiver em execução (depende compose)

is_vm_running() { [ "$(virsh list --state-running | grep -c "$VM_NAME")" -eq 1 ]; }

is_container_running() { [ "$(docker inspect --format '{{ .State.Running }}' "$CONTAINER_NAME" 2> /dev/null)" = "true" ]; }

start_vm() {
  echo "Iniciando a VM $VM_NAME..."
  virsh start "$VM_NAME"
  virsh resume "$VM_NAME"
}
ssh -o StrictHostKeyChecking=no root@media.lan bash /boot/config/plugins/user.scripts/scripts/vm_start_shared_gpu/script &

main() {

  if is_container_running; then
    # Para o container
    echo "Parando container $CONTAINER_NAME..."
    docker stop $CONTAINER_NAME
  fi

  if [ -n "$COMPOSE_FILE_PATH" ] && [ -n "$ENV_FILE_PATH" ]; then
    # Executar nova versão do container usando env file fornecido
    echo "Iniciando container $CONTAINER_NAME com env file $ENV_FILE_PATH..."
    docker-compose --env-file "$ENV_FILE_PATH" -f "$COMPOSE_FILE_PATH" up -d $CONTAINER_NAME
  fi

  sleep 1

  # Iniciar a VM
  start_vm
  sleep 30

  # Aguardar até que a VM não esteja mais em execução
  while is_vm_running; do
    sleep 60
  done

  if [ -n "$COMPOSE_FILE_PATH" ]; then
    # Reiniciar o container usando docker-compose
    echo "Reiniciando container $CONTAINER_NAME..."
    docker-compose -f "$COMPOSE_FILE_PATH" up -d $CONTAINER_NAME
  else
    # Reiniciar o container
    echo "Reiniciando container $CONTAINER_NAME..."
    docker start $CONTAINER_NAME
  fi
}

main

