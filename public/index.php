<?php

declare(strict_types=1);

require __DIR__ . '/../src/config.php';
require __DIR__ . '/../src/db.php';
require __DIR__ . '/../src/controllers.php';

session_start();

$pdo = getPdo();
$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);

if ($path === '/' || $path === '') {
    showQuizList($pdo);
    return;
}

if ($path === '/quiz') {
    showQuizQuestion($pdo);
    return;
}

if ($path === '/answer' && ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    handleAnswer($pdo);
    return;
}

if ($path === '/finish' && ($_SERVER['REQUEST_METHOD'] ?? '') === 'GET') {
    showFinishForm($pdo);
    return;
}

if ($path === '/finish' && ($_SERVER['REQUEST_METHOD'] ?? '') === 'POST') {
    handleFinish($pdo);
    return;
}

if ($path === '/results') {
    showResults($pdo);
    return;
}

http_response_code(404);
echo 'Not Found';
