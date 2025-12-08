-- 1. Добавляем семью
INSERT INTO Families (family_name, family_code) VALUES 
('Семья Ивановых', 'IVANOV2024'),
('Семья Петровых', 'PETROV2024');

-- 2. Добавляем членов семьи Ивановых
INSERT INTO FamilyMembers (family_id, username, email, role, avatar_color) VALUES
(1, 'Папа', 'papa@example.com', 'parent', '#3498db'),
(1, 'Мама', 'mama@example.com', 'parent', '#e74c3c'),
(1, 'Сын', 'son@example.com', 'child', '#2ecc71'),
(1, 'Дочь', 'daughter@example.com', 'child', '#9b59b6');

-- 3. Добавляем категории задач для семьи Ивановых
INSERT INTO TaskCategories (family_id, name, description, color, points_value, icon) VALUES
(1, 'Уборка', 'Домашние дела по уборке', '#1abc9c', 15, '🧹'),
(1, 'Покупки', 'Покупка продуктов и товаров', '#3498db', 10, '🛒'),
(1, 'Готовка', 'Приготовление еды', '#e74c3c', 20, '👨‍🍳'),
(1, 'Учеба', 'Учебные задания', '#f1c40f', 25, '📚'),
(1, 'Ремонт', 'Мелкий ремонт по дому', '#95a5a6', 30, '🔧');

-- 4. Добавляем задачи
INSERT INTO Tasks (family_id, title, description, due_date, priority, category_id, created_by, assigned_to) VALUES
(1, 'Помыть посуду', 'Вымыть всю накопившуюся посуду', '2024-12-15', 'medium', 1, 1, 3),
(1, 'Купить молоко', '2 литра молока и хлеб', '2024-12-14', 'high', 2, 2, 1),
(1, 'Сделать уроки', 'Математика и русский язык', '2024-12-16', 'high', 4, 1, 3),
(1, 'Починить кран', 'Капает кран на кухне', '2024-12-20', 'low', 5, 1, 1),
(1, 'Приготовить ужин', 'Спагетти болоньезе', '2024-12-15', 'medium', 3, 2, 2);

-- 5. Добавляем напоминания
INSERT INTO TaskReminders (task_id, reminder_date) VALUES
(1, '2024-12-14 18:00:00'),
(2, '2024-12-13 10:00:00'),
(3, '2024-12-15 16:00:00');

-- 6. Добавляем выполненные задачи с баллами
UPDATE Tasks SET status = 'completed', completed_by = 3, completed_at = datetime('now') WHERE task_id = 1;
INSERT INTO PointsHistory (member_id, task_id, points, reason) VALUES (3, 1, 15, 'task_completed');

UPDATE Tasks SET status = 'completed', completed_by = 1, completed_at = datetime('now') WHERE task_id = 2;
INSERT INTO PointsHistory (member_id, task_id, points, reason) VALUES (1, 2, 10, 'task_completed');
