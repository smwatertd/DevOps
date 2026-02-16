.PHONY: help docker native

help:
	@echo "Способы развертывания:"
	@echo ""
	@echo "make docker <команда>  - Управление через Docker Compose"
	@echo "make native <команда>  - Управление нативной установкой (без контейнеров)"

docker:
	@bash deployment/docker.sh $(filter-out $@,$(MAKECMDGOALS))

native:
	@bash deployment/native.sh $(filter-out $@,$(MAKECMDGOALS))

# Catch-all для аргументов docker/native
%:
	@:
