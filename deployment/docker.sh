#!/bin/bash
# Скрипт для управления приложением через Docker Compose

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

case "${1:-help}" in
    start)
        echo "Запуск приложения через Docker Compose..."
        docker compose up -d
        echo "✓ Приложение запущено: http://localhost/"
        ;;

    stop)
        echo "Остановка приложения..."
        docker compose down
        echo "✓ Приложение остановлено"
        ;;

    restart)
        echo "Перезапуск приложения..."
        docker compose restart
        echo "✓ Приложение перезапущено"
        ;;

    rebuild)
        echo "Пересборка и запуск приложения..."
        docker compose down
        docker compose up -d --build
        echo "✓ Приложение пересобрано и запущено"
        ;;
        
    clean)
        echo "Удаление контейнеров..."
        docker compose down --remove-orphans
        echo "✓ Контейнеры удалены"
        ;;

    reset)
        echo "Полная очистка (включая volumes и БД)..."
        docker compose down -v --remove-orphans
        docker compose up -d --build
        echo "✓ Приложение полностью пересоздано"
        ;;

    help|*)
        cat <<EOF
Управление приложением через Docker Compose

Использование: $0 <команда>

Команды:
  start    - Запустить приложение
  stop     - Остановить приложение
  restart  - Перезапустить приложение
  rebuild  - Пересобрать и запустить
  logs     - Показать логи (Ctrl+C для выхода)
  status   - Показать статус контейнеров
  clean    - Удалить контейнеры
  reset    - Полная очистка (включая БД)
  help     - Показать это сообщение

Примеры:
  $0 start
  $0 logs
  $0 reset
EOF
        ;;
esac
