// Family Task Manager - Основная логика

let tasks = JSON.parse(localStorage.getItem('familyTasks')) || [];
let members = JSON.parse(localStorage.getItem('familyMembers')) || [
    { id: 1, name: 'Папа', color: '#3498db' },
    { id: 2, name: 'Мама', color: '#e74c3c' },
    { id: 3, name: 'Ребёнок', color: '#2ecc71' }
];

// Инициализация при загрузке
document.addEventListener('DOMContentLoaded', function() {
    updateMembersList();
    updateTaskList();
    updateStats();
});

// Функция добавления задачи
function addTask() {
    const taskInput = document.getElementById('taskInput');
    const assigneeSelect = document.getElementById('taskAssignee');
    
    const taskText = taskInput.value.trim();
    const assigneeId = parseInt(assigneeSelect.value);
    
    // Валидация
    if (taskText === '') {
        alert('Введите текст задачи!');
        return;
    }
    
    if (!assigneeId) {
        alert('Выберите ответственного!');
        return;
    }
    
    // Создание новой задачи
    const newTask = {
        id: Date.now(),
        text: taskText,
        assigneeId: assigneeId,
        completed: false,
        createdAt: new Date().toISOString()
    };
    
    tasks.push(newTask);
    saveTasks();
    
    // Очистка полей
    taskInput.value = '';
    assigneeSelect.value = '';
    
    // Обновление интерфейса
    updateTaskList();
    updateStats();
    
    alert('Задача добавлена!');
}

// Сохранение задач в localStorage
function saveTasks() {
    localStorage.setItem('familyTasks', JSON.stringify(tasks));
}

// Обновление списка задач
function updateTaskList() {
    const taskList = document.getElementById('taskList');
    taskList.innerHTML = '';
    
    tasks.forEach(task => {
        const li = document.createElement('li');
        li.className = task.completed ? 'completed' : '';
        li.innerHTML = `
            <div class="task-content">
                <input type="checkbox" ${task.completed ? 'checked' : ''} 
                       onchange="toggleTask(${task.id})">
                <span>${task.text}</span>
                <span class="assignee-badge" style="background-color: ${getMemberColor(task.assigneeId)}">
                    ${getMemberName(task.assigneeId)}
                </span>
            </div>
            <button class="delete-btn" onclick="deleteTask(${task.id})">
                <i class="fas fa-trash"></i>
            </button>
        `;
        taskList.appendChild(li);
    });
}

// Получение имени члена семьи по ID
function getMemberName(id) {
    const member = members.find(m => m.id === id);
    return member ? member.name : 'Неизвестно';
}

// Получение цвета члена семьи
function getMemberColor(id) {
    const member = members.find(m => m.id === id);
    return member ? member.color : '#95a5a6';
}
// Управление членами семьи

// Обновление списка членов семьи
function updateMembersList() {
    const membersList = document.getElementById('membersList');
    const assigneeSelect = document.getElementById('taskAssignee');
    
    membersList.innerHTML = '';
    assigneeSelect.innerHTML = '<option value="">Выберите ответственного</option>';
    
    members.forEach(member => {
        // Отображение в секции "Члены семьи"
        const memberDiv = document.createElement('div');
        memberDiv.className = 'member-card';
        memberDiv.innerHTML = `
            <div class="member-avatar" style="background-color: ${member.color}">
                ${member.name.charAt(0)}
            </div>
            <span>${member.name}</span>
            <button class="btn-small" onclick="removeMember(${member.id})">
                <i class="fas fa-times"></i>
            </button>
        `;
        membersList.appendChild(memberDiv);
        
        // Добавление в выпадающий список
        const option = document.createElement('option');
        option.value = member.id;
        option.textContent = member.name;
        assigneeSelect.appendChild(option);
    });
    
    // Сохраняем в localStorage
    localStorage.setItem('familyMembers', JSON.stringify(members));
}

// Добавление нового члена семьи
function addMember() {
    const name = prompt('Введите имя нового члена семьи:');
    if (!name || name.trim() === '') return;
    
    const colors = ['#3498db', '#e74c3c', '#2ecc71', '#f39c12', '#9b59b6', '#1abc9c'];
    const newMember = {
        id: Date.now(),
        name: name.trim(),
        color: colors[members.length % colors.length]
    };
    
    members.push(newMember);
    updateMembersList();
}

// Удаление члена семьи
function removeMember(id) {
    if (!confirm('Удалить этого члена семьи?')) return;
    
    // Проверяем, есть ли задачи у этого члена
    const hasTasks = tasks.some(task => task.assigneeId === id);
    if (hasTasks) {
        alert('Нельзя удалить члена семьи, у которого есть задачи!');
        return;
    }
    
    members = members.filter(member => member.id !== id);
    updateMembersList();
}

// Переключение статуса задачи
function toggleTask(taskId) {
    const task = tasks.find(t => t.id === taskId);
    if (task) {
        task.completed = !task.completed;
        saveTasks();
        updateTaskList();
        updateStats();
    }
}

// Удаление задачи
function deleteTask(taskId) {
    if (!confirm('Удалить эту задачу?')) return;
    
    tasks = tasks.filter(t => t.id !== taskId);
    saveTasks();
    updateTaskList();
    updateStats();
}

// Обновление статистики
function updateStats() {
    const total = tasks.length;
    const completed = tasks.filter(t => t.completed).length;
    const pending = total - completed;
    
    document.getElementById('totalTasks').textContent = total;
    document.getElementById('completedTasks').textContent = completed;
    document.getElementById('pendingTasks').textContent = pending;
}

// Фильтрация задач
function filterTasks(filter) {
    const buttons = document.querySelectorAll('.filter-btn');
    buttons.forEach(btn => btn.classList.remove('active'));
    event.target.classList.add('active');
    
    // Здесь будет логика фильтрации (можно расширить)
    updateTaskList();
}
