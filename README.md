# Развертывание приложения

Приложение можно развернуть двумя способами:

## 1. Docker Compose (рекомендуется)

Простое развертывание в контейнерах.

### Требования
- Docker и Docker Compose

### Команды

```bash
# Запустить приложение
./deployment/docker.sh start

# Остановить
./deployment/docker.sh stop

# Перезапустить
./deployment/docker.sh restart

# Пересобрать с нуля
./deployment/docker.sh rebuild

# Полная очистка БД
./deployment/docker.sh reset

# Показать логи
./deployment/docker.sh logs

# Показать статус
./deployment/docker.sh status
```

Или через Makefile:
```bash
make docker start
make docker logs
make docker stop
```

Приложение будет доступно на `http://localhost/`

---

## 2. Нативная установка (без контейнеров)

Установка на Ubuntu 22.04 без использования Docker.

### Требования
- Ubuntu 22.04 (или совместимая система)
- Права sudo

### Команды

```bash
# 1. Установить зависимости
sudo ./deployment/native.sh install

# 2. Настроить БД и Nginx
sudo ./deployment/native.sh setup

# 3. Запустить сервисы
sudo ./deployment/native.sh start

# Остановить
sudo ./deployment/native.sh stop

# Перезапустить
sudo ./deployment/native.sh restart

# Показать статус
sudo ./deployment/native.sh status

# Показать логи
sudo ./deployment/native.sh logs
```

Или через Makefile:
```bash
make native install
make native setup
make native start
```

Приложение будет доступно на `http://<IP_сервера>/`

---

## Проверка работоспособности

```bash
make test
```

Или вручную:
```bash
curl http://localhost/
```

---

## Безопасность

В обоих вариантах развертывания:
- Пароли хранятся в `.env` файле (не в коде)
- Порт MySQL закрыт для внешнего доступа
- Открыт только порт 80 (HTTP)
- Nginx блокирует доступ к `.env` и `/src`
- Листинг директорий отключен

---

## Структура проекта

```
.
├── deployment/           # Скрипты развертывания
│   ├── docker.sh        # Управление Docker Compose
│   └── native.sh        # Управление нативной установкой
├── docker/              # Конфигурация Docker
│   ├── nginx.conf       # Nginx для контейнера
│   └── php/
│       ├── Dockerfile
│       └── php.ini
├── public/              # Публичная директория (точка входа)
│   └── index.php
├── src/                 # Бизнес-логика
│   ├── config.php
│   ├── controllers.php
│   └── db.php
├── templates/           # HTML-шаблоны
├── .env                 # Переменные окружения (создается при установке)
├── docker-compose.yml   # Конфигурация Docker Compose
├── schema.sql          # Схема БД
├── Makefile            # Упрощенные команды
└── README.md           # Этот файл
```
