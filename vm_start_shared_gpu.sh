#!/bin/bash

# Definir nomes da VM e do container
VM_NAME="Win11"
CONTAINER_NAME="ollama"
ENV_FILE_PATH="/mnt/user/appdata/llm-stack/cpu-only.env" # Opcional
COMPOSE_FILE_PATH="/mnt/user/appdata/llm-stack/docker-compose.yml" # Opcional

is_vm_running() { [ "$(virsh list --state-running | grep -c "$VM_NAME")" -eq 1 ]; }

is_container_running() { [ "$(docker inspect --format '{{ .State.Running }}' "$CONTAINER_NAME" 2> /dev/null)" = "true" ]; }

main() {

  if [ -n "$COMPOSE_FILE_PATH" ]; then
    # Parar container ou stack completa, em caso de falha
    docker-compose -f "$COMPOSE_FILE_PATH" stop "$CONTAINER_NAME" || docker-compose -f "$COMPOSE_FILE_PATH" down

    if [ -n "$ENV_FILE_PATH" ]; then
      # Executar nova versão do container usando env file fornecido
      docker-compose --env-file "$ENV_FILE_PATH" -f "$COMPOSE_FILE_PATH" up -d
    fi
  
  else
    # Parar o container
    docker stop $CONTAINER_NAME
  fi

  sleep 1

  virsh start $VM_NAME
  sleep 30

  while is_vm_running; do
    sleep 60
  done

  if [ -n "$COMPOSE_FILE_PATH" ]; then
    # Reiniciar o container usando docker-compose
    docker-compose -f "$COMPOSE_FILE_PATH" up -d
  else
    # Reiniciar o container
    docker start $CONTAINER_NAME
  fi
}

main
