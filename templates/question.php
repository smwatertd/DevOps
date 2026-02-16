<p class="muted">Вопрос <?php echo (int) $progress['current']; ?> из <?php echo (int) $progress['total']; ?></p>
<h2><?php echo e($questionText); ?></h2>

<?php if (empty($options)) : ?>
    <p>Нет вариантов ответа.</p>
<?php else : ?>
    <form method="post" action="/answer">
        <?php foreach ($options as $option) : ?>
            <label class="option">
                <input type="radio" name="option_id" value="<?php echo (int) $option['id']; ?>" required>
                <span style="margin-left:8px;"><?php echo e((string) $option['text']); ?></span>
            </label>
        <?php endforeach; ?>
        <button type="submit">Ответить</button>
    </form>
<?php endif; ?>
