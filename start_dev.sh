#!/bin/bash

# Quick start script for development
# This script starts both backend and frontend servers

set -e

echo "========================================="
echo "  Book Shop - Development Server Start  "
echo "========================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo -e "${RED}Error: backend or frontend directory not found.${NC}"
    echo "Please run this script from the project root directory."
    exit 1
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists ruby; then
    echo -e "${RED}Error: Ruby is not installed.${NC}"
    exit 1
fi

# Rails will be available via bundle exec, so we skip this check

if ! command_exists node; then
    echo -e "${RED}Error: Node.js is not installed.${NC}"
    exit 1
fi

if ! command_exists npm; then
    echo -e "${RED}Error: npm is not installed.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ All prerequisites installed${NC}"
echo ""

# Setup backend
echo -e "${YELLOW}Setting up backend...${NC}"
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
cd backend

if [ ! -f "config/database.yml" ]; then
    echo -e "${RED}Error: database.yml not found${NC}"
    exit 1
fi

# Check if bundle is needed
if [ ! -d "vendor/bundle" ] && [ ! -f ".bundle/config" ]; then
    echo "Installing Ruby gems..."
    bundle install
fi

# Check if database exists
if ! bundle exec rails db:version >/dev/null 2>&1; then
    echo "Creating database..."
    bundle exec rails db:create
    echo "Running migrations..."
    bundle exec rails db:migrate
    echo "Database setup complete!"

    # Ask about seeding
    read -p "Do you want to seed the database? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        bundle exec rails db:seed
    fi
fi

echo -e "${GREEN}✓ Backend ready${NC}"
echo ""

# Setup frontend
echo -e "${YELLOW}Setting up frontend...${NC}"
cd ../frontend

if [ ! -d "node_modules" ]; then
    echo "Installing npm packages..."
    npm install
fi

# Check if .env exists
if [ ! -f ".env" ]; then
    echo "Creating .env file..."
    cat > .env << EOF
PORT=3001
REACT_APP_API_URL=http://localhost:3000/api/v1
EOF
fi

echo -e "${GREEN}✓ Frontend ready${NC}"
echo ""

# Start servers
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Starting Development Servers${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "${YELLOW}Backend:${NC}  http://localhost:3000"
echo -e "${YELLOW}Frontend:${NC} http://localhost:3001"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all servers${NC}"
echo ""

cd ..

# Function to cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}Shutting down servers...${NC}"
    kill $(jobs -p) 2>/dev/null
    echo -e "${GREEN}All servers stopped${NC}"
    exit 0
}

trap cleanup SIGINT SIGTERM

# Start backend
echo -e "${YELLOW}Starting backend server...${NC}"
cd backend
export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
bundle exec rails server -p 3000 &
BACKEND_PID=$!
cd ..

# Wait a bit for backend to start
sleep 3

# Start frontend
echo -e "${YELLOW}Starting frontend server...${NC}"
cd frontend
npm start &
FRONTEND_PID=$!
cd ..

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}  Both servers are running!${NC}"
echo -e "${GREEN}=========================================${NC}"
echo ""
echo -e "Backend PID:  ${BACKEND_PID}"
echo -e "Frontend PID: ${FRONTEND_PID}"
echo ""

# Wait for both processes
wait
