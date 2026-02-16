#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_DIR="/var/www/poll-app"

cd "$PROJECT_DIR"

need_root() {
    [ "$EUID" -eq 0 ] || [ "$1" = "help" ] && return
    echo "need sudo"
    exit 1
}

case "${1:-help}" in
    install)
        need_root "$1"
        apt update && apt install -y software-properties-common
        add-apt-repository -y ppa:ondrej/php
        apt update && apt install -y nginx php8.1-fpm php8.1-mysql mysql-server curl
        echo "done"
        ;;

    setup)
        need_root "$1"
        if [ "$PROJECT_DIR" != "$APP_DIR" ]; then
            mkdir -p "$APP_DIR"
            cp -r "$PROJECT_DIR"/* "$PROJECT_DIR"/.[!.]* "$APP_DIR/" 2>/dev/null || true
            cd "$APP_DIR"
        fi

        read -sp "db pass: " DB_PASS && echo
        mysql -e "CREATE DATABASE IF NOT EXISTS poll_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
        mysql -e "CREATE USER IF NOT EXISTS 'poll_user'@'localhost' IDENTIFIED BY '$DB_PASS';"
        mysql -e "GRANT ALL PRIVILEGES ON poll_app.* TO 'poll_user'@'localhost';"
        mysql -e "FLUSH PRIVILEGES;"
        mysql -u poll_user -p"$DB_PASS" poll_app < "$APP_DIR/schema.sql"

        cat > "$APP_DIR/.env" <<EOF
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=poll_app
DB_USER=poll_user
DB_PASS=$DB_PASS
DB_ROOT_PASS=unused
EOF
        chmod 600 "$APP_DIR/.env"
        chown -R www-data:www-data "$APP_DIR"
        chmod 755 "$APP_DIR"
        find "$APP_DIR" -type f -exec chmod 644 {} \;
        chmod 600 "$APP_DIR/.env"

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
        nginx -t && echo "ok"
        ;;

    start)
        need_root "$1"
        systemctl start mysql php8.1-fpm nginx
        echo "running"
        ;;

    stop)
        need_root "$1"
        systemctl stop nginx php8.1-fpm mysql
        echo "stopped"
        ;;

    restart)
        need_root "$1"
        systemctl restart mysql php8.1-fpm nginx
        ;;

    status)
        systemctl status nginx php8.1-fpm mysql --no-pager 2>&1 | head -20
        ;;

    help|*)
        cat <<EOF
usage: $0 {install|setup|start|stop|restart|status}
EOF
        ;;
esac
