<p class="muted">Результаты прохождения тестов.</p>

<?php if (empty($rows)) : ?>
    <p>Пока нет результатов.</p>
<?php else : ?>
    <table style="width:100%; border-collapse: collapse;">
        <thead>
            <tr>
                <th style="text-align: left; padding: 12px; border-bottom: 2px solid #e2e8f0;">Имя</th>
                <th style="text-align: left; padding: 12px; border-bottom: 2px solid #e2e8f0;">Название теста</th>
                <th style="text-align: center; padding: 12px; border-bottom: 2px solid #e2e8f0;">Результат</th>
            </tr>
        </thead>
        <tbody>
            <?php foreach ($rows as $row) : ?>
                <tr>
                    <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;"><?php echo e((string) $row['user_name']); ?></td>
                    <td style="padding: 10px; border-bottom: 1px solid #e5e7eb;"><?php echo e((string) $row['title']); ?></td>
                    <td style="padding: 10px; border-bottom: 1px solid #e5e7eb; text-align: center;">
                        <strong><?php echo (int) $row['correct_count']; ?>/<?php echo (int) $row['total_count']; ?></strong>
                    </td>
                </tr>
            <?php endforeach; ?>
        </tbody>
    </table>
<?php endif; ?>
