<!DOCTYPE html>
<html lang="ru">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?php echo e($pageTitle); ?></title>
    <style>
        :root {
            --bg: #f6f4ef;
            --card: #ffffff;
            --text: #1f2933;
            --accent: #ea580c;
            --muted: #6b7280;
            --star: #fbbf24;
            --star-muted: #e5e7eb;
        }
        body {
            margin: 0;
            font-family: "Georgia", "Times New Roman", serif;
            background: linear-gradient(160deg, #fef3c7, #f6f4ef 55%, #e2e8f0 100%);
            color: var(--text);
        }
        .wrap {
            max-width: 780px;
            margin: 48px auto;
            padding: 0 20px;
        }
        header {
            margin-bottom: 24px;
        }
        h1 {
            font-size: 32px;
            margin: 0 0 8px;
            letter-spacing: 0.5px;
        }
        nav a {
            margin-right: 12px;
            text-decoration: none;
            color: var(--accent);
        }
        .card {
            background: var(--card);
            border-radius: 14px;
            padding: 24px;
            box-shadow: 0 10px 24px rgba(15, 23, 42, 0.12);
        }
        .option {
            display: flex;
            align-items: center;
            margin: 10px 0;
        }
        .quiz-card {
            padding: 16px;
            border: 1px solid #e2e8f0;
            border-radius: 12px;
            margin-bottom: 16px;
            background: #fffaf2;
        }
        .quiz-title {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 12px;
        }
        .difficulty {
            display: flex;
            align-items: center;
            gap: 8px;
            color: var(--muted);
            font-size: 14px;
        }
        .stars-label {
            letter-spacing: 0.3px;
        }
        .stars {
            font-size: 18px;
            letter-spacing: 2px;
        }
        .star {
            color: var(--star-muted);
        }
        .star.filled {
            color: var(--star);
        }
        .meta {
            margin-top: 8px;
            color: var(--muted);
        }
        button {
            background: var(--accent);
            color: #ffffff;
            border: none;
            padding: 10px 18px;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
        }
        .muted {
            color: var(--muted);
        }
        .result-row {
            display: flex;
            justify-content: space-between;
            border-bottom: 1px solid #e5e7eb;
            padding: 8px 0;
        }
        .result-row:last-child {
            border-bottom: none;
        }
    </style>
</head>
<body>
    <div class="wrap">
        <header>
            <h1><?php echo e($pageTitle); ?></h1>
            <nav>
                <a href="/">Темы</a>
                <a href="/results">Результаты</a>
            </nav>
        </header>
        <div class="card">
            <?php echo $content; ?>
        </div>
    </div>
</body>
</html>
