Отчет по заданию (PHP + Nginx + MySQL)

1. Краткое описание приложения
Приложение — простой опросник. Главная страница показывает вопрос и варианты ответа. После отправки ответа пользователь попадает на страницу результатов, где видно количество голосов по каждому варианту.

Маршруты:
- / — форма опроса
- /submit — обработка ответа (POST)
- /results — результаты опроса

2. Структура проекта и файлы
Корень проекта: /var/www/poll-app (для варианта без контейнеров) или директория репозитория (для Docker Compose).

Ключевые файлы:
- public/index.php — точка входа и простой роутинг.
- src/config.php — загрузка переменных окружения из .env.
- src/db.php — подключение к MySQL (PDO).
- src/controllers.php — обработчики маршрутов.
- templates/*.php — шаблоны HTML.
- schema.sql — схема БД и тестовые данные.
- .env — конфигурация доступа к БД (секреты вне кода).
- docker-compose.yml — compose-конфигурация.
- docker/nginx.conf — конфиг Nginx для контейнеров.
- docker/php/Dockerfile — образ PHP-FPM с pdo_mysql.

3. Вариант 1: развертывание без контейнеров (Ubuntu 22.04)

3.1. Установка пакетов
sudo apt update
sudo apt install -y nginx php-fpm php-mysql mysql-server

3.2. Подготовка MySQL
sudo mysql

Внутри MySQL:
CREATE DATABASE poll_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'poll_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON poll_app.* TO 'poll_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

Импорт схемы:
mysql -u poll_user -p poll_app < /var/www/poll-app/schema.sql

3.3. Размещение приложения
Скопировать проект в /var/www/poll-app. Убедиться, что права позволяют Nginx читать файлы:
sudo chown -R www-data:www-data /var/www/poll-app
sudo find /var/www/poll-app -type d -exec chmod 755 {} \;
sudo find /var/www/poll-app -type f -exec chmod 644 {} \;

3.4. Конфигурация .env
Создать /var/www/poll-app/.env на основе .env.example и указать корректные параметры:
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=poll_app
DB_USER=poll_user
DB_PASS=strong_password
DB_ROOT_PASS=unused_here

3.5. Конфигурация Nginx
Файл: /etc/nginx/sites-available/poll-app

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

Активировать сайт:
sudo ln -s /etc/nginx/sites-available/poll-app /etc/nginx/sites-enabled/poll-app
sudo nginx -t
sudo systemctl reload nginx

3.6. Firewall
Открыть только HTTP:
sudo ufw allow 80

Порт 3306 (MySQL) не открывать наружу.

4. Вариант 2: Docker Compose

4.1. Установка Docker и Compose
sudo apt update
sudo apt install -y docker.io docker-compose-plugin
sudo usermod -aG docker $USER

4.2. Настройка переменных окружения
В файле .env (в корне проекта) указать сильные пароли:
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=poll_app
DB_USER=poll_user
DB_PASS=strong_password
DB_ROOT_PASS=strong_root_password

4.3. Запуск
Из корня проекта:
docker compose up -d --build

Доступность: http://<IP_ВМ>/

Порт MySQL наружу не публикуется; БД доступна только внутри сети compose.

5. Безопасность
- Пароли вынесены в .env и не находятся в коде.
- Для Nginx запрещен доступ к /src и /.env.
- Во внешний мир открыт только порт 80.
- База данных доступна только локально (вариант 1) или в сети compose (вариант 2).

6. Проверка работоспособности
- Открыть главную страницу (/), выбрать вариант ответа и отправить.
- Перейти на /results и убедиться, что счетчик голосов увеличился.

7. Где находятся ключевые конфигурации
- Nginx (без контейнеров): /etc/nginx/sites-available/poll-app
- Nginx (compose): docker/nginx.conf
- PHP-FPM (compose): docker/php/Dockerfile и docker/php/php.ini
- MySQL схема: schema.sql
- Переменные окружения: .env

8. Схема БД (кратко)
Таблицы и назначение:
- polls — список опросов (id, title).
- questions — вопросы, привязанные к опросу (poll_id).
- options — варианты ответа, привязанные к вопросу (question_id).
- responses — зафиксированные ответы (option_id, created_at).

Связи:
- polls (1) -> (N) questions
- questions (1) -> (N) options
- options (1) -> (N) responses

9. Чек-лист демонстрации преподавателю
- Открыть главную страницу и показать вопрос с вариантами.
- Отправить ответ и перейти на страницу результатов.
- Показать рост счетчика голосов.
- Показать, что .env не отдается через веб (403).
- Показать, что порт 3306 не открыт наружу.

10. Быстрая проверка
Проверка доступности приложения:
curl -I http://<IP_ВМ>/

Проверка, что .env недоступен:
curl -I http://<IP_ВМ>/.env

Проверка закрытого порта MySQL (на клиентской машине):
nc -zv <IP_ВМ> 3306

Пример сценария через браузер:
1) Открыть http://<IP_ВМ>/
2) Выбрать вариант ответа и отправить.
3) Открыть http://<IP_ВМ>/results
