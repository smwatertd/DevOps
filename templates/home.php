<p class="muted">Выберите тему теста.</p>

<?php if (empty($quizzes)) : ?>
    <p>Пока нет доступных тестов.</p>
<?php else : ?>
    <?php foreach ($quizzes as $quiz) : ?>
        <div class="quiz-card">
            <div class="quiz-title">
                <h2><?php echo e((string) $quiz['title']); ?></h2>
                <div class="difficulty">
                    <span class="stars-label">Сложность</span>
                    <div class="stars" aria-label="Сложность: <?php echo (int) $quiz['difficulty']; ?>">
                        <?php for ($i = 1; $i <= 5; $i++) : ?>
                            <span class="star<?php echo $i <= (int) $quiz['difficulty'] ? ' filled' : ''; ?>">★</span>
                        <?php endfor; ?>
                    </div>
                </div>
            </div>
            <p class="meta"><?php echo e((string) $quiz['description']); ?></p>
            <a href="/quiz?id=<?php echo (int) $quiz['id']; ?>">
                <button type="button">Начать</button>
            </a>
        </div>
    <?php endforeach; ?>
<?php endif; ?>
