#!/bin/bash
# Скрипт для управления приложением без контейнеров (Ubuntu 22.04)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_DIR="/var/www/poll-app"

cd "$PROJECT_DIR"

check_root() {
    if [ "$EUID" -ne 0 ] && [ "$1" != "help" ]; then 
        echo "Ошибка: большинство команд требуют sudo"
        echo "Запустите: sudo $0 $1"
        exit 1
    fi
}

case "${1:-help}" in
    install)
        check_root "$1"
        echo "Установка зависимостей..."
        apt update
        apt install -y nginx php-fpm php-mysql mysql-server curl
        echo "✓ Зависимости установлены"
        ;;
    
    setup)
        check_root "$1"
        echo "=== Настройка приложения ==="
        
        # Копирование файлов
        if [ "$PROJECT_DIR" != "$APP_DIR" ]; then
            echo "Копирование файлов в $APP_DIR..."
            mkdir -p "$APP_DIR"
            cp -r "$PROJECT_DIR"/* "$APP_DIR/"
            cd "$APP_DIR"
        fi
        
        # Настройка БД
        read -sp "Введите пароль для MySQL пользователя poll_user: " DB_PASS
        echo ""
        
        mysql -e "CREATE DATABASE IF NOT EXISTS poll_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        mysql -e "CREATE USER IF NOT EXISTS 'poll_user'@'localhost' IDENTIFIED BY '$DB_PASS';"
        mysql -e "GRANT ALL PRIVILEGES ON poll_app.* TO 'poll_user'@'localhost';"
        mysql -e "FLUSH PRIVILEGES;"
        
        mysql -u poll_user -p"$DB_PASS" poll_app < "$APP_DIR/schema.sql"
        
        # Создание .env
        cat > "$APP_DIR/.env" <<EOF
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=poll_app
DB_USER=poll_user
DB_PASS=$DB_PASS
DB_ROOT_PASS=unused
EOF
        chmod 600 "$APP_DIR/.env"
        
        # Настройка прав
        chown -R www-data:www-data "$APP_DIR"
        find "$APP_DIR" -type d -exec chmod 755 {} \;
        find "$APP_DIR" -type f -exec chmod 644 {} \;
        chmod 600 "$APP_DIR/.env"
        
        # Настройка Nginx
        cat > /etc/nginx/sites-available/poll-app <<'EOF'
server {
    listen 80;
    server_name _;

    root /var/www/poll-app/public;
    index index.php;

    location / {
        try_files $uri /index.php?$query_string;
    }

    location ~ \.php$ {
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
    }

    location ^~ /src {
        deny all;
    }

    location ~ /\.env {
        deny all;
    }
}
EOF
        
        rm -f /etc/nginx/sites-enabled/default
        ln -sf /etc/nginx/sites-available/poll-app /etc/nginx/sites-enabled/poll-app
        nginx -t
        
        echo "✓ Настройка завершена"
        echo ""
        echo "Запустите сервисы: sudo $0 start"
        ;;
    
    start)
        check_root "$1"
        echo "Запуск сервисов..."
        systemctl start mysql
        systemctl start php8.1-fpm
        systemctl start nginx
        echo "✓ Сервисы запущены: http://localhost/"
        ;;
    
    stop)
        check_root "$1"
        echo "Остановка сервисов..."
        systemctl stop nginx
        systemctl stop php8.1-fpm
        systemctl stop mysql
        echo "✓ Сервисы остановлены"
        ;;
    
    restart)
        check_root "$1"
        echo "Перезапуск сервисов..."
        systemctl restart mysql
        systemctl restart php8.1-fpm
        systemctl restart nginx
        echo "✓ Сервисы перезапущены"
        ;;
    
    status)
        echo "=== Статус сервисов ==="
        systemctl status nginx --no-pager -l || true
        echo ""
        systemctl status php8.1-fpm --no-pager -l || true
        echo ""
        systemctl status mysql --no-pager -l || true
        ;;
    
    logs)
        echo "=== Логи Nginx (последние 50 строк) ==="
        tail -n 50 /var/log/nginx/error.log
        echo ""
        echo "=== Логи PHP-FPM ==="
        tail -n 50 /var/log/php8.1-fpm.log 2>/dev/null || journalctl -u php8.1-fpm -n 50 --no-pager
        ;;
    
    help|*)
        cat <<EOF
Управление приложением без контейнеров (native)

Использование: sudo $0 <команда>

Команды:
  install  - Установить зависимости (nginx, php-fpm, mysql)
  setup    - Настроить БД, Nginx и создать .env
  start    - Запустить сервисы
  stop     - Остановить сервисы
  restart  - Перезапустить сервисы
  status   - Показать статус сервисов
  logs     - Показать логи
  help     - Показать это сообщение

Пример установки:
  sudo $0 install
  sudo $0 setup
  sudo $0 start

Проверка работы:
  curl http://localhost/
EOF
        ;;
esac
