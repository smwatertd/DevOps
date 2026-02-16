.PHONY: help docker native test

help:
	@echo "=== Управление развертыванием ==="
	@echo ""
	@echo "Выберите способ развертывания:"
	@echo ""
	@echo "  make docker <команда>  - Управление через Docker Compose"
	@echo "  make native <команда>  - Управление нативной установкой (без контейнеров)"
	@echo ""
	@echo "  make test              - Проверить доступность приложения"
	@echo ""
	@echo "Для подробной справки:"
	@echo "  make docker help"
	@echo "  make native help"
	@echo ""
	@echo "Примеры:"
	@echo "  make docker start      # Запустить через Docker"
	@echo "  make native install    # Установить зависимости для нативной установки"

docker:
	@bash deployment/docker.sh $(filter-out $@,$(MAKECMDGOALS))

native:
	@bash deployment/native.sh $(filter-out $@,$(MAKECMDGOALS))

test:
	@echo "Проверка доступности приложения..."
	@curl -I http://localhost/ 2>/dev/null | head -n 1 || echo "Приложение недоступно"
	@echo ""
	@echo "Проверка, что .env недоступен..."
	@curl -I http://localhost/.env 2>/dev/null | head -n 1 || echo "OK: .env заблокирован"

# Catch-all для аргументов docker/native
%:
	@:
