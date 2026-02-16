#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_DIR"

case "${1:-help}" in
    start)
        docker compose up -d && echo "running"
        ;;

    stop)
        docker compose down && echo "stopped"
        ;;

    restart)
        docker compose restart
        ;;

    clean)
        docker compose down --remove-orphans && echo "cleaned"
        ;;

    help|*)
        cat <<EOF
usage: $0 {start|stop|restart|clean}
EOF
        ;;
esac
