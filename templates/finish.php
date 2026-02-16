<p class="muted">Вы завершили тест.</p>
<h2><?php echo e($quizTitle); ?></h2>
<p class="meta">Всего вопросов: <?php echo (int) $total; ?>.</p>

<form method="post" action="/finish">
    <label class="option">
        <span style="margin-right:8px;">Ваше имя:</span>
        <input type="text" name="user_name" maxlength="60" required>
    </label>
    <button type="submit">Сохранить результат</button>
</form>
