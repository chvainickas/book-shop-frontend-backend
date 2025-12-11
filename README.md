# Book Shop

A full-stack book shop application with a decoupled frontend and backend architecture.

## Project Structure

```
├── backend/    # Rails API application
├── frontend/   # React application
```

## Backend (Rails)

Rails API serving book catalog, user authentication, shopping cart, orders, and wishlist functionality.

### Setup

```bash
cd backend
bundle install
rails db:setup
rails server -p 3001
```

## Frontend (React)

React application providing the user interface for browsing books, managing cart, and placing orders.

### Setup

```bash
cd frontend
npm install
npm start
```

## Quick Start

```bash
# Start both services
./start_dev.sh
```

- Frontend: http://localhost:3000
- Backend API: http://localhost:3001
