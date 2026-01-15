# Todo API

A RESTful API for managing todos built with NestJS, TypeORM, and PostgreSQL 17.

## Prerequisites

- [Bun](https://bun.sh/) runtime
- PostgreSQL 17

## Setup

1. Install dependencies:
```bash
bun install
```

2. Configure environment variables:
```bash
cp .env.example .env
```

Edit `.env` with your PostgreSQL credentials:
```
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_USER=postgres
DATABASE_PASSWORD=postgres
DATABASE_NAME=todo_db
PORT=3000
```

3. Create the database:
```bash
createdb todo_db
```

## Running the API

```bash
# Development mode
bun run start:dev

# Production mode
bun run build
bun run start:prod
```

The API will be available at `http://localhost:3000`

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | /todos | Get all todos |
| GET | /todos/:id | Get a todo by ID |
| POST | /todos | Create a new todo |
| PATCH | /todos/:id | Update a todo |
| PATCH | /todos/:id/toggle | Toggle todo completion |
| DELETE | /todos/:id | Delete a todo |

## Request/Response Examples

### Create Todo
```bash
curl -X POST http://localhost:3000/todos \
  -H "Content-Type: application/json" \
  -d '{"title": "Buy groceries", "description": "Milk, eggs, bread"}'
```

### Update Todo
```bash
curl -X PATCH http://localhost:3000/todos/:id \
  -H "Content-Type: application/json" \
  -d '{"status": "in_progress"}'
```

## Tech Stack

- **Runtime**: Bun
- **Framework**: NestJS
- **ORM**: TypeORM
- **Database**: PostgreSQL 17
- **Validation**: class-validator
