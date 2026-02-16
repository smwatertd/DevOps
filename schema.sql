SET NAMES utf8mb4;
SET CHARACTER SET utf8mb4;

CREATE TABLE IF NOT EXISTS quizzes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    difficulty TINYINT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS questions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id INT NOT NULL,
    text VARCHAR(255) NOT NULL,
    CONSTRAINT fk_questions_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS options (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    text VARCHAR(255) NOT NULL,
    is_correct TINYINT(1) NOT NULL DEFAULT 0,
    CONSTRAINT fk_options_question FOREIGN KEY (question_id) REFERENCES questions(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS attempts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    quiz_id INT NOT NULL,
    user_name VARCHAR(60) NOT NULL,
    correct_count INT NOT NULL,
    total_count INT NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_attempts_quiz FOREIGN KEY (quiz_id) REFERENCES quizzes(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS attempt_answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    attempt_id INT NOT NULL,
    question_id INT NOT NULL,
    option_id INT NOT NULL,
    is_correct TINYINT(1) NOT NULL,
    CONSTRAINT fk_attempt_answers_attempt FOREIGN KEY (attempt_id) REFERENCES attempts(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_attempt_answers_question FOREIGN KEY (question_id) REFERENCES questions(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_attempt_answers_option FOREIGN KEY (option_id) REFERENCES options(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO quizzes (id, title, description, difficulty)
VALUES
    (1, 'Основы DevOps', 'Инструменты и практики, которые встречаются каждый день.', 3),
    (2, 'Linux и сеть', 'Базовые команды и понятия сетей.', 2)
ON DUPLICATE KEY UPDATE title = VALUES(title), description = VALUES(description), difficulty = VALUES(difficulty);

INSERT INTO questions (id, quiz_id, text)
VALUES
    (1, 1, 'Что означает CI?'),
    (2, 1, 'Какой инструмент чаще всего используют для контейнеризации?'),
    (3, 1, 'Какой файл описывает инфраструктуру в Terraform?'),
    (4, 2, 'Какой командой посмотреть активные соединения?'),
    (5, 2, 'Какой порт использует SSH по умолчанию?')
ON DUPLICATE KEY UPDATE text = VALUES(text);

INSERT INTO options (id, question_id, text, is_correct)
VALUES
    (1, 1, 'Continuous Integration', 1),
    (2, 1, 'Centralized Interface', 0),
    (3, 1, 'Cloud Instances', 0),
    (4, 2, 'Docker', 1),
    (5, 2, 'Kubernetes', 0),
    (6, 2, 'Ansible', 0),
    (7, 3, 'main.tf', 1),
    (8, 3, 'Dockerfile', 0),
    (9, 3, 'playbook.yml', 0),
    (10, 4, 'ss', 1),
    (11, 4, 'ls', 0),
    (12, 4, 'pwd', 0),
    (13, 5, '22', 1),
    (14, 5, '80', 0),
    (15, 5, '443', 0)
ON DUPLICATE KEY UPDATE text = VALUES(text), is_correct = VALUES(is_correct);
