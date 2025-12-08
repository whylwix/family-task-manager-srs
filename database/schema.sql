-- НОРМАЛИЗОВАННАЯ СХЕМА БАЗЫ ДАННЫХ ДЛЯ FAMILY TASK MANAGER
-- Соответствует 3NF (Третьей нормальной форме)
-- Версия: 1.0.0
-- Дата: 2024

-- 1. ТАБЛИЦА СЕМЕЙ
CREATE TABLE Families (
    family_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_name TEXT NOT NULL,
    family_code TEXT UNIQUE, -- уникальный код для приглашений
    created_at TEXT DEFAULT (datetime('now', 'localtime')),
    updated_at TEXT DEFAULT (datetime('now', 'localtime')),
    
    CHECK (LENGTH(family_name) >= 2)
);

-- 2. ТАБЛИЦА ЧЛЕНОВ СЕМЬИ
CREATE TABLE FamilyMembers (
    member_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_id INTEGER NOT NULL,
    username TEXT NOT NULL,
    email TEXT,
    role TEXT NOT NULL CHECK(role IN ('parent', 'child', 'guest')),
    avatar_color TEXT DEFAULT '#3498db',
    total_points INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT 1,
    created_at TEXT DEFAULT (datetime('now', 'localtime')),
    updated_at TEXT DEFAULT (datetime('now', 'localtime')),
    
    FOREIGN KEY (family_id) REFERENCES Families(family_id) ON DELETE CASCADE,
    UNIQUE(family_id, username),
    CHECK (LENGTH(username) >= 2)
);

-- 3. ТАБЛИЦА КАТЕГОРИЙ ЗАДАЧ
CREATE TABLE TaskCategories (
    category_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_id INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    color TEXT DEFAULT '#95a5a6',
    points_value INTEGER DEFAULT 10,
    icon TEXT DEFAULT '📝',
    is_default BOOLEAN DEFAULT 0,
    created_at TEXT DEFAULT (datetime('now', 'localtime')),
    
    FOREIGN KEY (family_id) REFERENCES Families(family_id) ON DELETE CASCADE,
    UNIQUE(family_id, name),
    CHECK (points_value >= 0)
);

-- 4. ОСНОВНАЯ ТАБЛИЦА ЗАДАЧ
CREATE TABLE Tasks (
    task_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    due_date TEXT, -- DATE в SQLite хранится как TEXT
    priority TEXT DEFAULT 'medium' CHECK(priority IN ('low', 'medium', 'high')),
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'in_progress', 'completed', 'cancelled')),
    category_id INTEGER,
    created_by INTEGER NOT NULL, -- кто создал задачу
    assigned_to INTEGER, -- кому назначена
    completed_by INTEGER, -- кто выполнил
    completed_at TEXT,
    created_at TEXT DEFAULT (datetime('now', 'localtime')),
    updated_at TEXT DEFAULT (datetime('now', 'localtime')),
    
    FOREIGN KEY (family_id) REFERENCES Families(family_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES TaskCategories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES FamilyMembers(member_id),
    FOREIGN KEY (assigned_to) REFERENCES FamilyMembers(member_id),
    FOREIGN KEY (completed_by) REFERENCES FamilyMembers(member_id),
    CHECK (LENGTH(title) >= 3)
);

-- 5. ТАБЛИЦА НАПОМИНАНИЙ
CREATE TABLE TaskReminders (
    reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    reminder_date TEXT NOT NULL,
    reminder_type TEXT DEFAULT 'push' CHECK(reminder_type IN ('push', 'email')),
    is_sent BOOLEAN DEFAULT 0,
    sent_at TEXT,
    created_at TEXT DEFAULT (datetime('now', 'localtime')),
    
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) ON DELETE CASCADE
);

-- 6. ИСТОРИЯ НАЧИСЛЕНИЯ БАЛЛОВ
CREATE TABLE PointsHistory (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    points INTEGER NOT NULL,
    reason TEXT CHECK(reason IN ('task_completed', 'bonus', 'penalty')),
    earned_at TEXT DEFAULT (datetime('now', 'localtime')),
    
    FOREIGN KEY (member_id) REFERENCES FamilyMembers(member_id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) ON DELETE CASCADE,
    CHECK (points != 0)
);

-- 7. ТАБЛИЦА ПОВТОРЯЮЩИХСЯ ЗАДАЧ
CREATE TABLE RecurringTasks (
    recurrence_id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    recurrence_type TEXT CHECK(recurrence_type IN ('daily', 'weekly', 'monthly')),
    recurrence_data TEXT, -- JSON с настройками
    next_date TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at TEXT DEFAULT (datetime('now', 'localtime')),
    
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) ON DELETE CASCADE
);

-- 8. ТАБЛИЦА ПРИГЛАШЕНИЙ В СЕМЬЮ
CREATE TABLE FamilyInvitations (
    invitation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_id INTEGER NOT NULL,
    invite_code TEXT UNIQUE NOT NULL,
    email TEXT,
    invited_by INTEGER NOT NULL,
    status TEXT DEFAULT 'pending' CHECK(status IN ('pending', 'accepted', 'expired')),
    expires_at TEXT,
    created_at TEXT DEFAULT (datetime('now', 'localtime')),
    
    FOREIGN KEY (family_id) REFERENCES Families(family_id) ON DELETE CASCADE,
    FOREIGN KEY (invited_by) REFERENCES FamilyMembers(member_id)
);

-- ИНДЕКСЫ ДЛЯ ОПТИМИЗАЦИИ ЗАПРОСОВ
CREATE INDEX idx_familymembers_family_id ON FamilyMembers(family_id);
CREATE INDEX idx_familymembers_role ON FamilyMembers(role);
CREATE INDEX idx_tasks_family_id ON Tasks(family_id);
CREATE INDEX idx_tasks_assigned_to ON Tasks(assigned_to);
CREATE INDEX idx_tasks_status ON Tasks(status);
CREATE INDEX idx_tasks_due_date ON Tasks(due_date);
CREATE INDEX idx_tasks_category_id ON Tasks(category_id);
CREATE INDEX idx_tasks_priority ON Tasks(priority);
CREATE INDEX idx_taskcategories_family_id ON TaskCategories(family_id);
CREATE INDEX idx_points_history_member_id ON PointsHistory(member_id);
CREATE INDEX idx_points_history_task_id ON PointsHistory(task_id);
CREATE INDEX idx_task_reminders_task_id ON TaskReminders(task_id);
CREATE INDEX idx_task_reminders_date ON TaskReminders(reminder_date);
CREATE INDEX idx_family_invitations_code ON FamilyInvitations(invite_code);

-- ТРИГГЕРЫ ДЛЯ АВТОМАТИЧЕСКИХ ОБНОВЛЕНИЙ

-- Триггер для обновления updated_at в Tasks
CREATE TRIGGER update_tasks_timestamp 
AFTER UPDATE ON Tasks
BEGIN
    UPDATE Tasks 
    SET updated_at = datetime('now', 'localtime')
    WHERE task_id = NEW.task_id;
END;

-- Триггер для обновления баллов члена семьи
CREATE TRIGGER update_member_points 
AFTER INSERT ON PointsHistory
BEGIN
    UPDATE FamilyMembers 
    SET total_points = total_points + NEW.points,
        updated_at = datetime('now', 'localtime')
    WHERE member_id = NEW.member_id;
END;

-- Триггер для обновления статуса задачи при завершении
CREATE TRIGGER update_task_on_completion
AFTER UPDATE OF completed_by ON Tasks
WHEN NEW.completed_by IS NOT NULL AND OLD.completed_by IS NULL
BEGIN
    UPDATE Tasks 
    SET status = 'completed',
        completed_at = datetime('now', 'localtime'),
        updated_at = datetime('now', 'localtime')
    WHERE task_id = NEW.task_id;
END;

-- Триггер для создания записи в истории баллов при завершении задачи
CREATE TRIGGER create_points_on_task_completion
AFTER UPDATE OF completed_by ON Tasks
WHEN NEW.completed_by IS NOT NULL AND OLD.completed_by IS NULL
BEGIN
    INSERT INTO PointsHistory (member_id, task_id, points, reason)
    SELECT 
        NEW.completed_by,
        NEW.task_id,
        COALESCE((SELECT points_value FROM TaskCategories WHERE category_id = NEW.category_id), 10),
        'task_completed';
END;

-- КОММЕНТАРИИ К ТАБЛИЦАМ (документация в БД)
COMMENT ON TABLE Families IS 'Хранит информацию о семьях (семейных группах)';
COMMENT ON TABLE FamilyMembers IS 'Члены семьи с ролями и баллами';
COMMENT ON TABLE TaskCategories IS 'Категории задач с настройками баллов';
COMMENT ON TABLE Tasks IS 'Основные задачи с назначением и сроками';
COMMENT ON TABLE TaskReminders IS 'Напоминания о предстоящих задачах';
COMMENT ON TABLE PointsHistory IS 'История начисления баллов за выполненные задачи';
COMMENT ON TABLE RecurringTasks IS 'Повторяющиеся задачи с настройками периодичности';
COMMENT ON TABLE FamilyInvitations IS 'Приглашения для присоединения к семье';

-- ПРОЦЕДУРА ДЛЯ ПОЛУЧЕНИЯ СТАТИСТИКИ СЕМЬИ (опционально)
-- В SQLite нет хранимых процедур, но можно создать VIEW
CREATE VIEW FamilyStats AS
SELECT 
    f.family_id,
    f.family_name,
    COUNT(DISTINCT fm.member_id) as total_members,
    COUNT(DISTINCT t.task_id) as total_tasks,
    COUNT(DISTINCT CASE WHEN t.status = 'completed' THEN t.task_id END) as completed_tasks,
    SUM(fm.total_points) as total_points_earned,
    MAX(t.created_at) as last_task_date
FROM Families f
LEFT JOIN FamilyMembers fm ON f.family_id = fm.family_id
LEFT JOIN Tasks t ON f.family_id = t.family_id
GROUP BY f.family_id, f.family_name;

-- ПРЕДСТАВЛЕНИЕ ДЛЯ ОТЧЁТА ПО ВЫПОЛНЕНИЮ ЗАДАЧ
CREATE VIEW TaskCompletionReport AS
SELECT 
    t.family_id,
    DATE(t.completed_at) as completion_date,
    COUNT(*) as tasks_completed,
    SUM(ph.points) as points_earned,
    GROUP_CONCAT(fm.username) as completed_by_members
FROM Tasks t
JOIN PointsHistory ph ON t.task_id = ph.task_id
JOIN FamilyMembers fm ON ph.member_id = fm.member_id
WHERE t.status = 'completed'
GROUP BY t.family_id, DATE(t.completed_at);
