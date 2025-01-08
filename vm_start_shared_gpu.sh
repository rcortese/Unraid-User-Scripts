#!/bin/bash

# Definir nomes da VM e do container
VM_NAME="Win11"
CONTAINER_NAME="ollama"

# Opcional: Reinicia o container com o env file fornecido enquanto a VM estiver em execução
COMPOSE_FILE_PATH="/mnt/user/appdata/llm-stack/docker-compose.yaml"
ENV_FILE_PATH="/mnt/user/appdata/llm-stack/cpu-only.env"

# Funções auxiliares

is_vm_running() { [ "$(virsh list --state-running | grep -c "$VM_NAME")" -eq 1 ]; }

is_container_running() { [ "$(docker inspect --format '{{ .State.Running }}' "$CONTAINER_NAME" 2> /dev/null)" = "true" ]; }

start_vm() {
  echo "Iniciando a VM $VM_NAME..."
  virsh start "$VM_NAME"
  virsh resume "$VM_NAME"
}

# Função principal

main() {
  local start_alternate_container=false

  if is_container_running; then
    # Para o container
    echo "Parando container $CONTAINER_NAME..."
    docker stop $CONTAINER_NAME
  fi

  if [ -n "$COMPOSE_FILE_PATH" ] && [ -n "$ENV_FILE_PATH" ]; then

    start_alternate_container=true

    # Executar nova versão do container usando env file fornecido
    echo "Iniciando container $CONTAINER_NAME com env file $ENV_FILE_PATH..."
    docker-compose --env-file "$ENV_FILE_PATH" -f "$COMPOSE_FILE_PATH" up -d $CONTAINER_NAME
  fi

  # Iniciar a VM
  start_vm
  sleep 30

  # Aguardar até que a VM não esteja mais em execução
  until ! is_vm_running; do
    sleep 60
  done
  echo "VM $VM_NAME não está mais em execução."

  if $start_alternate_container; then
    # Restaurar o container original usando docker-compose
    echo "Restaurando container $CONTAINER_NAME com .env original..."
    docker-compose -f "$COMPOSE_FILE_PATH" up -d $CONTAINER_NAME
  else
    # Reiniciar o container
    echo "Reiniciando container $CONTAINER_NAME..."
    docker start $CONTAINER_NAME
  fi
  
  exit 0
}

main
