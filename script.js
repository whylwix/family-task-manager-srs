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
