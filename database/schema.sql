
-- 1. ТАБЛИЦА СЕМЕЙ
CREATE TABLE Families (
    family_id INTEGER PRIMARY KEY AUTOINCREMENT,
    family_name TEXT NOT NULL,
    family_code TEXT UNIQUE, -- для приглашений
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now'))
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
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    
    FOREIGN KEY (family_id) REFERENCES Families(family_id) ON DELETE CASCADE,
    UNIQUE(family_id, username)
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
    created_at TEXT DEFAULT (datetime('now')),
    
    FOREIGN KEY (family_id) REFERENCES Families(family_id) ON DELETE CASCADE,
    UNIQUE(family_id, name)
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
    created_at TEXT DEFAULT (datetime('now')),
    updated_at TEXT DEFAULT (datetime('now')),
    
    FOREIGN KEY (family_id) REFERENCES Families(family_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES TaskCategories(category_id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES FamilyMembers(member_id),
    FOREIGN KEY (assigned_to) REFERENCES FamilyMembers(member_id),
    FOREIGN KEY (completed_by) REFERENCES FamilyMembers(member_id)
);

-- 5. ТАБЛИЦА НАПОМИНАНИЙ
CREATE TABLE TaskReminders (
    reminder_id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    reminder_date TEXT NOT NULL,
    reminder_type TEXT DEFAULT 'push' CHECK(reminder_type IN ('push', 'email')),
    is_sent BOOLEAN DEFAULT 0,
    sent_at TEXT,
    created_at TEXT DEFAULT (datetime('now')),
    
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) ON DELETE CASCADE
);

-- 6. ИСТОРИЯ БАЛЛОВ
CREATE TABLE PointsHistory (
    history_id INTEGER PRIMARY KEY AUTOINCREMENT,
    member_id INTEGER NOT NULL,
    task_id INTEGER NOT NULL,
    points INTEGER NOT NULL,
    reason TEXT CHECK(reason IN ('task_completed', 'bonus', 'penalty')),
    earned_at TEXT DEFAULT (datetime('now')),
    
    FOREIGN KEY (member_id) REFERENCES FamilyMembers(member_id) ON DELETE CASCADE,
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) ON DELETE CASCADE
);

-- 7. ТАБЛИЦА ПОВТОРЯЮЩИХСЯ ЗАДАЧ (опционально)
CREATE TABLE RecurringTasks (
    recurrence_id INTEGER PRIMARY KEY AUTOINCREMENT,
    task_id INTEGER NOT NULL,
    recurrence_type TEXT CHECK(recurrence_type IN ('daily', 'weekly', 'monthly')),
    recurrence_data TEXT, -- JSON с настройками
    next_date TEXT,
    is_active BOOLEAN DEFAULT 1,
    created_at TEXT DEFAULT (datetime('now')),
    
    FOREIGN KEY (task_id) REFERENCES Tasks(task_id) ON DELETE CASCADE
);

-- ИНДЕКСЫ ДЛЯ ОПТИМИЗАЦИИ
CREATE INDEX idx_familymembers_family_id ON FamilyMembers(family_id);
CREATE INDEX idx_tasks_family_id ON Tasks(family_id);
CREATE INDEX idx_tasks_assigned_to ON Tasks(assigned_to);
CREATE INDEX idx_tasks_status ON Tasks(status);
CREATE INDEX idx_tasks_due_date ON Tasks(due_date);
CREATE INDEX idx_taskcategories_family_id ON TaskCategories(family_id);
CREATE INDEX idx_points_history_member_id ON PointsHistory(member_id);
CREATE INDEX idx_task_reminders_task_id ON TaskReminders(task_id);

-- ТРИГГЕР ДЛЯ ОБНОВЛЕНИЯ БАЛЛОВ ПРИ ВЫПОЛНЕНИИ ЗАДАЧИ
CREATE TRIGGER update_member_points 
AFTER INSERT ON PointsHistory
BEGIN
    UPDATE FamilyMembers 
    SET total_points = total_points + NEW.points,
        updated_at = datetime('now')
    WHERE member_id = NEW.member_id;
END;
