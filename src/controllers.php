<?php

declare(strict_types=1);

function e(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function render(string $template, array $vars = []): void
{
    extract($vars, EXTR_SKIP);

    ob_start();
    require __DIR__ . '/../templates/' . $template . '.php';
    $content = ob_get_clean();

    $pageTitle = $pageTitle ?? 'Poll App';
    require __DIR__ . '/../templates/layout.php';
}

function showQuizList(PDO $pdo): void
{
    $quizzes = $pdo->query(
        'SELECT id, title, description, difficulty '
        . 'FROM quizzes '
        . 'ORDER BY id ASC'
    )->fetchAll();

    render('home', [
        'pageTitle' => 'Темы тестов',
        'quizzes' => $quizzes,
    ]);
}

function showQuizQuestion(PDO $pdo): void
{
    $quizId = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);

    if ($quizId) {
        startQuizSession($pdo, $quizId);
    }

    $state = $_SESSION['quiz'] ?? null;
    if (!$state) {
        header('Location: /');
        return;
    }

    $questionId = getCurrentQuestionId($state);
    if ($questionId === null) {
        header('Location: /finish');
        return;
    }

    $question = getQuestionById($pdo, $questionId);
    $options = getOptionsByQuestion($pdo, $questionId);
    $quiz = getQuizById($pdo, (int) $state['quiz_id']);

    render('question', [
        'pageTitle' => $quiz ? $quiz['title'] : 'Тест',
        'questionText' => $question ? (string) $question['text'] : 'Вопрос не найден',
        'options' => $options,
        'progress' => [
            'current' => (int) $state['current_index'] + 1,
            'total' => count($state['question_ids']),
        ],
    ]);
}

function handleAnswer(PDO $pdo): void
{
    $state = $_SESSION['quiz'] ?? null;
    if (!$state) {
        header('Location: /');
        return;
    }

    $questionId = getCurrentQuestionId($state);
    if ($questionId === null) {
        header('Location: /finish');
        return;
    }

    $optionId = filter_input(INPUT_POST, 'option_id', FILTER_VALIDATE_INT);
    if (!$optionId) {
        http_response_code(400);
        echo 'Некорректный выбор';
        return;
    }

    $stmt = $pdo->prepare('SELECT id FROM options WHERE id = ? AND question_id = ?');
    $stmt->execute([$optionId, $questionId]);
    if (!$stmt->fetch()) {
        http_response_code(400);
        echo 'Некорректный вариант ответа';
        return;
    }

    $state['answers'][(string) $questionId] = (int) $optionId;
    $state['current_index']++;
    $_SESSION['quiz'] = $state;

    if ($state['current_index'] >= count($state['question_ids'])) {
        header('Location: /finish');
        return;
    }

    header('Location: /quiz');
}

function showFinishForm(PDO $pdo): void
{
    $state = $_SESSION['quiz'] ?? null;
    if (!$state) {
        header('Location: /');
        return;
    }

    if ($state['current_index'] < count($state['question_ids'])) {
        header('Location: /quiz');
        return;
    }

    $quiz = getQuizById($pdo, (int) $state['quiz_id']);

    render('finish', [
        'pageTitle' => 'Завершение теста',
        'quizTitle' => $quiz ? (string) $quiz['title'] : 'Тест',
        'total' => count($state['question_ids']),
    ]);
}

function handleFinish(PDO $pdo): void
{
    $state = $_SESSION['quiz'] ?? null;
    if (!$state) {
        header('Location: /');
        return;
    }

    if ($state['current_index'] < count($state['question_ids'])) {
        header('Location: /quiz');
        return;
    }

    $name = trim((string) filter_input(INPUT_POST, 'user_name', FILTER_UNSAFE_RAW));
    if ($name === '' || mb_strlen($name) > 60) {
        http_response_code(400);
        echo 'Введите имя (до 60 символов)';
        return;
    }

    $answers = $state['answers'] ?? [];
    $optionIds = array_values($answers);
    $correctMap = [];
    $correctCount = 0;

    if ($optionIds) {
        $placeholders = implode(', ', array_fill(0, count($optionIds), '?'));
        $stmt = $pdo->prepare('SELECT id, is_correct FROM options WHERE id IN (' . $placeholders . ')');
        $stmt->execute($optionIds);
        foreach ($stmt->fetchAll() as $row) {
            $correctMap[(int) $row['id']] = (int) $row['is_correct'] === 1;
        }
    }

    foreach ($answers as $optionId) {
        if (!empty($correctMap[(int) $optionId])) {
            $correctCount++;
        }
    }

    $pdo->beginTransaction();
    try {
        $insertAttempt = $pdo->prepare(
            'INSERT INTO attempts (quiz_id, user_name, correct_count, total_count, created_at) '
            . 'VALUES (?, ?, ?, ?, NOW())'
        );
        $insertAttempt->execute([
            (int) $state['quiz_id'],
            $name,
            $correctCount,
            count($state['question_ids']),
        ]);
        $attemptId = (int) $pdo->lastInsertId();

        $insertAnswer = $pdo->prepare(
            'INSERT INTO attempt_answers (attempt_id, question_id, option_id, is_correct) '
            . 'VALUES (?, ?, ?, ?)'
        );

        foreach ($answers as $questionId => $optionId) {
            $isCorrect = !empty($correctMap[(int) $optionId]) ? 1 : 0;
            $insertAnswer->execute([
                $attemptId,
                (int) $questionId,
                (int) $optionId,
                $isCorrect,
            ]);
        }

        $pdo->commit();
    } catch (Throwable $e) {
        $pdo->rollBack();
        http_response_code(500);
        echo 'Ошибка сохранения результата';
        return;
    }

    unset($_SESSION['quiz']);
    header('Location: /results');
}

function showResults(PDO $pdo): void
{
    $rows = $pdo->query(
        'SELECT a.user_name, q.title, a.correct_count, a.total_count, a.created_at '
        . 'FROM attempts a '
        . 'JOIN quizzes q ON q.id = a.quiz_id '
        . 'ORDER BY a.created_at DESC '
        . 'LIMIT 200'
    )->fetchAll();

    render('results', [
        'pageTitle' => 'Результаты',
        'rows' => $rows,
    ]);
}

function startQuizSession(PDO $pdo, int $quizId): void
{
    $quiz = getQuizById($pdo, $quizId);
    if (!$quiz) {
        return;
    }

    $questions = getQuestionsByQuiz($pdo, $quizId);
    if (!$questions) {
        return;
    }

    $_SESSION['quiz'] = [
        'quiz_id' => $quizId,
        'question_ids' => array_column($questions, 'id'),
        'answers' => [],
        'current_index' => 0,
    ];
}

function getCurrentQuestionId(array $state): ?int
{
    $index = (int) ($state['current_index'] ?? 0);
    $ids = $state['question_ids'] ?? [];
    if (!isset($ids[$index])) {
        return null;
    }

    return (int) $ids[$index];
}

function getQuizById(PDO $pdo, int $quizId): ?array
{
    $stmt = $pdo->prepare('SELECT id, title FROM quizzes WHERE id = ?');
    $stmt->execute([$quizId]);
    $quiz = $stmt->fetch();
    return $quiz ?: null;
}

function getQuestionsByQuiz(PDO $pdo, int $quizId): array
{
    $stmt = $pdo->prepare('SELECT id FROM questions WHERE quiz_id = ? ORDER BY id ASC');
    $stmt->execute([$quizId]);
    return $stmt->fetchAll();
}

function getQuestionById(PDO $pdo, int $questionId): ?array
{
    $stmt = $pdo->prepare('SELECT id, text FROM questions WHERE id = ?');
    $stmt->execute([$questionId]);
    $question = $stmt->fetch();
    return $question ?: null;
}

function getOptionsByQuestion(PDO $pdo, int $questionId): array
{
    $stmt = $pdo->prepare('SELECT id, text FROM options WHERE question_id = ? ORDER BY id ASC');
    $stmt->execute([$questionId]);
    return $stmt->fetchAll();
}
