# API Testing Documentation
## Family Task Manager API

## Mock Server URL
```
https://your-mock-id.mock.pstmn.io
```

## Quick Start

### 1. Import Collection
1. Open Postman
2. Click **Import** → **Upload Files**
3. Select: `postman/Family_Task_Manager_API_Collection.json`

### 2. Import Environment  
1. In Postman, go to **Environments**
2. Click **Import**
3. Select: `postman/Family_Task_Manager_Local_Environment.json`

### 3. Set Mock Server URL
1. Select environment **"Family Task Manager Local"**
2. Click **Edit**
3. Set `base_url` to your Mock Server URL
4. Save

### 4. Run Tests
1. Open **"Login User"** request
2. Click **Send**
3. Check **Test Results** tab

## Available Endpoints

### Authentication
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | User login |

### Family Management  
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/families` | Create new family |
| GET | `/api/families/{id}/members` | Get family members |
| POST | `/api/families/{id}/invite` | Invite family member |

### Tasks Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/families/{id}/tasks` | Create family task |
| GET | `/api/families/{id}/tasks` | Get family tasks |
| PATCH | `/api/tasks/{id}/complete` | Mark task as completed |
| GET | `/api/families/{id}/stats` | Get task statistics |

### Categories Management
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/families/{id}/categories` | Get categories |
| POST | `/api/families/{id}/categories` | Create category |

## Test Scenarios

### Scenario 1: User Registration & Login
```
1. Register User → Get 201 Created
2. Login User → Get 200 OK + auth_token
```

### Scenario 2: Family Creation & Task Management  
```
1. Login User → Save token
2. Create Family → Save family_id  
3. Create Family Task → Save task_id
4. Complete Task → Verify completion
5. Get Statistics → Verify points
```

### Scenario 3: Error Handling
```
1. Login with wrong credentials → Get 401
2. Create task without title → Get 400
3. Access without token → Get 401
```

## Request Examples

### Login Request
```json
POST {{base_url}}/auth/login
{
    "username": "family_admin",
    "password": "securepass123"
}
```

### Create Family Task Request
```json
POST {{base_url}}/api/families/{{family_id}}/tasks
Authorization: Bearer {{auth_token}}
{
    "title": "Купить продукты",
    "description": "Молоко, хлеб, яйца",
    "priority": "high",
    "category_id": 1,
    "due_date": "2024-12-20",
    "assignee_id": 2
}
```

## Test Examples

### Login Tests
```javascript
pm.test("Status code is 200", function() {
    pm.response.to.have.status(200);
});

pm.test("Response has auth token", function() {
    var jsonData = pm.response.json();
    pm.expect(jsonData.token).to.not.be.undefined;
});
```

### Task Creation Tests  
```javascript
pm.test("Task created - status 201", function() {
    pm.response.to.have.status(201);
});

pm.test("Save task ID", function() {
    var jsonData = pm.response.json();
    pm.environment.set("task_id", jsonData.task_id);
});
```

## Files Structure

```
docs/api/
├── README.md                    # This file
├── postman/
│   ├── Family_Task_Manager_API_Collection.json
│   └── Family_Task_Manager_Local_Environment.json
└── screenshots/                 # Optional: Postman screenshots
```

## Related Documentation

- [Use Cases](../requirements/use-cases.md)
- [ER Diagram](../database/er_diagram.png)  
- [Sequence Diagrams](../behavior/sequence/)

---

## Troubleshooting

### Problem: "Invalid URL"
**Solution:** Check that `base_url` is set in environment variables.

### Problem: "401 Unauthorized"
**Solution:** Run Login request first to get valid `auth_token`.

### Problem: Mock Server returns wrong example
**Solution:** Check that request URL and parameters match Example conditions.

### Problem: Tests failing
**Solution:** Check console logs in Postman (View → Show Postman Console).

---

**Postman Version:** 10.20+
