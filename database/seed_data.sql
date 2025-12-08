-- ТЕСТОВЫЕ ДАННЫЕ ДЛЯ FAMILY TASK MANAGER
-- Вставляются после выполнения schema.sql

-- 1. ДОБАВЛЯЕМ ТЕСТОВЫЕ СЕМЬИ
INSERT INTO Families (family_name, family_code) VALUES 
('Семья Ивановых', 'IVANOV2024'),
('Семья Петровых', 'PETROV2024'),
('Семья Сидоровых', 'SIDOROV2024');

-- 2. ДОБАВЛЯЕМ ЧЛЕНОВ СЕМЬИ ИВАНОВЫХ
INSERT INTO FamilyMembers (family_id, username, email, role, avatar_color) VALUES
(1, 'Алексей Иванов', 'alexey@example.com', 'parent', '#3498db'),
(1, 'Мария Иванова', 'maria@example.com', 'parent', '#e74c3c'),
(1, 'Иван Иванов', 'ivan@example.com', 'child', '#2ecc71'),
(1, 'Анна Иванова', 'anna@example.com', 'child', '#9b59b6');

-- 3. ДОБАВЛЯЕМ ЧЛЕНОВ СЕМЬИ ПЕТРОВЫХ
INSERT INTO FamilyMembers (family_id, username, email, role, avatar_color) VALUES
(2, 'Дмитрий Петров', 'dmitry@example.com', 'parent', '#1abc9c'),
(2, 'Ольга Петрова', 'olga@example.com', 'parent', '#f39c12'),
(2, 'Михаил Петров', 'mikhail@example.com', 'child', '#34495e');

-- 4. СОЗДАЁМ КАТЕГОРИИ ЗАДАЧ ДЛЯ СЕМЬИ ИВАНОВЫХ
INSERT INTO TaskCategories (family_id, name, description, color, points_value, icon, is_default) VALUES
(1, 'Уборка', 'Домашние дела по уборке', '#1abc9c', 15, '🧹', 1),
(1, 'Покупки', 'Покупка продуктов и товаров', '#3498db', 10, '🛒', 1),
(1, 'Готовка', 'Приготовление еды', '#e74c3c', 20, '👨‍🍳', 1),
(1, 'Учеба', 'Учебные задания и уроки', '#f1c40f', 25, '📚', 1),
(1, 'Ремонт', 'Мелкий ремонт по дому', '#95a5a6', 30, '🔧', 0),
(1, 'Спорт', 'Спортивные занятия', '#e67e22', 15, '⚽', 0);

-- 5. СОЗДАЁМ КАТЕГОРИИ ДЛЯ СЕМЬИ ПЕТРОВЫХ
INSERT INTO TaskCategories (family_id, name, description, color, points_value, icon) VALUES
(2, 'Работа в саду', 'Уход за растениями', '#27ae60', 20, '🌱'),
(2, 'Уборка', 'Уборка помещений', '#1abc9c', 15, '🧹');

-- 6. ДОБАВЛЯЕМ ЗАДАЧИ ДЛЯ СЕМЬИ ИВАНОВЫХ
INSERT INTO Tasks (family_id, title, description, due_date, priority, category_id, created_by, assigned_to) VALUES
-- Активные задачи
(1, 'Помыть посуду', 'Вымыть всю накопившуюся посуду на кухне', '2024-12-15', 'medium', 1, 1, 3),
(1, 'Купить молоко и хлеб', '2 литра молока и батон хлеба', '2024-12-14', 'high', 2, 2, 1),
(1, 'Сделать уроки по математике', 'Стр. 45-48, задачи №1-10', '2024-12-16', 'high', 4, 1, 3),
(1, 'Починить кран на кухне', 'Капает кран, нужна замена прокладки', '2024-12-20', 'low', 5, 1, 1),
(1, 'Приготовить ужин', 'Спагетти болоньезе с салатом', '2024-12-15', 'medium', 3, 2, 2),
(1, 'Пропылесосить гостиную', 'Полная уборка пылесосом', '2024-12-17', 'medium', 1, 1, 4),
(1, 'Сходить в спортивный зал', 'Тренировка 1.5 часа', '2024-12-18', 'low', 6, 3, 3),

-- Выполненные задачи (для истории)
(1, 'Вынести мусор', 'Все ведра на кухне и в ванной', '2024-12-13', 'medium', 1, 2, 3),
(1, 'Купить корм для кота', 'Royal Canin для взрослых котов', '2024-12-12', 'high', 2, 1, 2),
(1, 'Подготовить доклад по истории', 'Тема: Вторая мировая война', '2024-12-10', 'high', 4, 3, 3);

-- 7. ДОБАВЛЯЕМ ЗАДАЧИ ДЛЯ СЕМЬИ ПЕТРОВЫХ
INSERT INTO Tasks (family_id, title, description, due_date, priority, category_id, created_by, assigned_to) VALUES
(2, 'Полить цветы', 'Все комнатные растения', '2024-12-16', 'low', 7, 5, 7),
(2, 'Убраться в гараже', 'Разложить инструменты по местам', '2024-12-19', 'medium', 8, 6, 5);

-- 8. ОТМЕЧАЕМ НЕКОТОРЫЕ ЗАДАЧИ ВЫПОЛНЕННЫМИ
UPDATE Tasks SET 
    status = 'completed', 
    completed_by = 3, 
    completed_at = datetime('now', '-2 days', 'localtime')
WHERE task_id IN (8, 9, 10);

-- 9. ДОБАВЛЯЕМ НАПОМИНАНИЯ ДЛЯ АКТИВНЫХ ЗАДАЧ
INSERT INTO TaskReminders (task_id, reminder_date) VALUES
(1, datetime('now', '+1 day', 'localtime')),
(2, datetime('now', '+6 hours', 'localtime')),
(3, datetime('now', '+2 days', 'localtime')),
(4, datetime('now', '+5 days', 'localtime')),
(5, datetime('now', '+1 day', 'localtime'));

-- 10. ДОБАВЛЯЕМ ПОВТОРЯЮЩУЮСЯ ЗАДАЧУ
INSERT INTO Tasks (family_id, title, description, due_date, priority, category_id, created_by, assigned_to) VALUES
(1, 'Выгулять собаку', 'Утренняя прогулка с собакой', '2024-12-16', 'medium', 1, 2, 4);

INSERT INTO RecurringTasks (task_id, recurrence_type, recurrence_data, next_date) VALUES
(13, 'daily', '{"time": "08:00", "skip_weekends": false}', '2024-12-17');

-- 11. СОЗДАЁМ ПРИГЛАШЕНИЕ В СЕМЬЮ
INSERT INTO FamilyInvitations (family_id, invite_code, email, invited_by, expires_at) VALUES
(1, 'IVANOV-INVITE-001', 'grandma@example.com', 1, datetime('now', '+7 days', 'localtime')),
(2, 'PETROV-GUEST-2024', 'friend@example.com', 5, datetime('now', '+3 days', 'localtime'));

-- 12. ПРОВЕРЯЕМ ЧТО БАЛЛЫ АВТОМАТИЧЕСКИ НАЧИСЛИЛИСЬ ЧЕРЕЗ ТРИГГЕР
-- (После обновления статуса задач триггеры автоматически создали записи в PointsHistory)

-- 13. РУЧНОЕ ДОБАВЛЕНИЕ БОНУСНЫХ БАЛЛОВ (если нужно)
INSERT INTO PointsHistory (member_id, task_id, points, reason) VALUES
(3, 8, 5, 'bonus'), -- бонус за быструю сдачу
(2, 9, 3, 'bonus'); -- бонус за дополнительную покупку

-- 14. ОБНОВЛЯЕМ СТАТИСТИКУ (автоматически через триггеры)
-- Триггеры уже обновили total_points в FamilyMembers

-- 15. ТЕСТОВЫЙ ЗАПРОС ДЛЯ ПРОВЕРКИ ДАННЫХ
SELECT '=== ТЕСТОВЫЕ ДАННЫЕ УСПЕШНО ДОБАВЛЕНЫ ===' as message;

-- 16. ВЫВОД СТАТИСТИКИ ДЛЯ ПРОВЕРКИ
SELECT 
    f.family_name,
    COUNT(DISTINCT fm.member_id) as members_count,
    COUNT(DISTINCT t.task_id) as tasks_count,
    COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.task_id END) as completed_tasks,
    SUM(fm.total_points) as total_points
FROM Families f
LEFT JOIN FamilyMembers fm ON f.family_id = fm.family_id
LEFT JOIN Tasks t ON f.family_id = t.family_id
GROUP BY f.family_id, f.family_name
ORDER BY f.family_id;

-- 17. ВЫВОД СПИСКА ЗАДАЧ С ИНФОРМАЦИЕЙ
SELECT 
    t.task_id,
    f.family_name,
    t.title,
    tc.name as category,
    creator.username as created_by,
    assignee.username as assigned_to,
    t.status,
    t.due_date,
    t.priority,
    tc.points_value as potential_points
FROM Tasks t
JOIN Families f ON t.family_id = f.family_id
LEFT JOIN TaskCategories tc ON t.category_id = tc.category_id
LEFT JOIN FamilyMembers creator ON t.created_by = creator.member_id
LEFT JOIN FamilyMembers assignee ON t.assigned_to = assignee.member_id
ORDER BY t.due_date, t.priority DESC;
