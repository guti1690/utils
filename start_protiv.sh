
#!/bin/bash

# Start all servers needed for the Protiv app
# This script starts Docker Compose, Ember dashboard, React dashboard, and proxy server

set -e  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory - adjust this path if needed
BASE_DIR="$HOME/projects/protiv-v2"

# Function to print colored messages
print_msg() {
    echo -e "${GREEN}[PROTIV]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"j
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Function to check if directory exists
check_directory() {
    if [ ! -d "$1" ]; then
        print_error "Directory $1 does not exist!"
        exit 1
    fi
}

# Function to check if pnpm is installed
check_pnpm() {
    if ! command -v pnpm &> /dev/null; then
        print_error "pnpm is not installed. Please install pnpm first."
        exit 1
    fi
}

# Function to check if docker-compose is installed
check_docker_compose() {
    if ! command -v docker-compose &> /dev/null && ! command -v docker &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker and Docker Compose first."
        exit 1
    fi
}

# Function to kill processes on script exit
cleanup() {
    print_warning "Stopping all servers..."

    # Kill all background jobs started by this script
    jobs -p | xargs -r kill

    # Stop docker compose
    if [ -d "$BASE_DIR/protiv-rails" ]; then
        cd "$BASE_DIR/protiv-rails"
        docker-compose down 2>/dev/null || true
    fi

    print_msg "All servers stopped."
    exit 0
}

# Set up signal handlers for cleanup
trap cleanup SIGINT SIGTERM

print_msg "Starting Protiv application servers..."

# Check prerequisites
print_info "Checking prerequisites..."
check_pnpm
check_docker_compose

# Check if base directory exists
check_directory "$BASE_DIR"

# Check all required directories
print_info "Checking required directories..."
check_directory "$BASE_DIR/protiv-rails"
check_directory "$BASE_DIR/@protiv/dashboard"
check_directory "$BASE_DIR/@protiv/dashboard-react"
check_directory "$BASE_DIR/@protiv/proxy-server"

print_msg "All directories found. Starting services..."

# 1. Start Docker Compose from protiv-rails directory
print_info "Starting Docker Compose services (PostgreSQL, Redis)..."
cd "$BASE_DIR/protiv-rails"
docker-compose up -d
if [ $? -ne 0 ]; then
    print_error "Failed to start Docker Compose services"
    exit 1
fi
print_msg "Docker Compose services started"

# Wait a moment for databases to be ready
print_info "Waiting for databases to be ready..."
sleep 5

# 2. Start Ember dashboard
print_info "Starting Ember dashboard on port 4200..."
cd "$BASE_DIR/@protiv/dashboard"
pnpm start > /tmp/ember_dashboard.log 2>&1 &
EMBER_PID=$!
print_msg "Ember dashboard started (PID: $EMBER_PID)"

# 3. Start React dashboard
print_info "Starting React dashboard on port 5173..."
cd "$BASE_DIR/@protiv/dashboard-react"
pnpm start > /tmp/react_dashboard.log 2>&1 &
REACT_PID=$!
print_msg "React dashboard started (PID: $REACT_PID)"

# 4. Start proxy server
print_info "Starting proxy server on port 5400..."
cd "$BASE_DIR/@protiv/proxy-server"
PORT=5400 pnpm run dev > /tmp/proxy_server.log 2>&1 &
PROXY_PID=$!
print_msg "Proxy server started (PID: $PROXY_PID)"

# Wait for services to start up
print_info "Waiting for services to start up..."
sleep 10

# Check if services are running
print_info "Checking service status..."

# Check if processes are still running
if ! kill -0 $EMBER_PID 2>/dev/null; then
    print_error "Ember dashboard failed to start. Check logs at /tmp/ember_dashboard.log"
    exit 1
fi

if ! kill -0 $REACT_PID 2>/dev/null; then
    print_error "React dashboard failed to start. Check logs at /tmp/react_dashboard.log"
    exit 1
fi

if ! kill -0 $PROXY_PID 2>/dev/null; then
    print_error "Proxy server failed to start. Check logs at /tmp/proxy_server.log"
    exit 1
fi

print_msg "All services are running successfully!"
print_msg ""
print_msg "🚀 Protiv app is now available at: http://localhost:5400"
print_msg ""
print_msg "Service URLs:"
print_msg "  • Proxy Server:    http://localhost:5400"
print_msg "  • Ember Dashboard: http://localhost:4200"
print_msg "  • React Dashboard: http://localhost:5173"
print_msg ""
print_msg "Logs are available at:"
print_msg "  • Ember Dashboard: /tmp/ember_dashboard.log"
print_msg "  • React Dashboard: /tmp/react_dashboard.log"
print_msg "  • Proxy Server:    /tmp/proxy_server.log"
print_msg ""
print_warning "Press Ctrl+C to stop all services"

# Keep the script running and display logs
while true; do
    sleep 5

    # Check if any service has died
    if ! kill -0 $EMBER_PID 2>/dev/null; then
        print_error "Ember dashboard has stopped unexpectedly!"
        break
    fi

    if ! kill -0 $REACT_PID 2>/dev/null; then
        print_error "React dashboard has stopped unexpectedly!"
        break
    fi

    if ! kill -0 $PROXY_PID 2>/dev/null; then
        print_error "Proxy server has stopped unexpectedly!"
        break
    fi
done

# If we get here, something went wrong
cleanup
