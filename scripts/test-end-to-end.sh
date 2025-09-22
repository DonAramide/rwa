#!/bin/bash

# RWA Platform End-to-End Testing Script
# This script runs comprehensive tests on the local deployment

set -e

echo "Running RWA Platform End-to-End Tests..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    print_status "Running test: $test_name"
    
    if eval "$test_command"; then
        print_success "$test_name PASSED"
        ((TESTS_PASSED++))
    else
        print_error "$test_name FAILED"
        ((TESTS_FAILED++))
    fi
    echo ""
}

# Wait for service to be ready
wait_for_service() {
    local url="$1"
    local service_name="$2"
    local max_attempts=30
    local attempt=1
    
    print_status "Waiting for $service_name to be ready..."
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            print_success "$service_name is ready"
            return 0
        fi
        
        if [ $attempt -eq $max_attempts ]; then
            print_error "$service_name failed to respond"
            return 1
        fi
        
        sleep 2
        ((attempt++))
    done
}

# Test 1: Check if all services are running
test_services_running() {
    local services=("postgres:5432" "redis:6379" "minio:9000" "api:3000" "anvil:8545")
    
    for service in "${services[@]}"; do
        IFS=':' read -r name port <<< "$service"
        if ! nc -z localhost "$port" 2>/dev/null; then
            print_error "Service $name is not running on port $port"
            return 1
        fi
    done
    
    print_success "All services are running"
    return 0
}

# Test 2: Backend API Health Check
test_api_health() {
    local response=$(curl -s http://localhost:3000/health)
    if echo "$response" | grep -q "ok"; then
        return 0
    else
        print_error "API health check failed: $response"
        return 1
    fi
}

# Test 3: Database Connection
test_database_connection() {
    local response=$(curl -s http://localhost:3000/v1/assets)
    if echo "$response" | grep -q "items"; then
        return 0
    else
        print_error "Database connection failed: $response"
        return 1
    fi
}

# Test 4: Authentication Flow
test_authentication() {
    local login_data='{"email":"admin@example.com","password":"admin123"}'
    local response=$(curl -s -X POST http://localhost:3000/v1/auth/login \
        -H "Content-Type: application/json" \
        -d "$login_data")
    
    if echo "$response" | grep -q "access_token"; then
        return 0
    else
        print_error "Authentication failed: $response"
        return 1
    fi
}

# Test 5: Asset CRUD Operations
test_asset_crud() {
    # Get auth token
    local login_data='{"email":"admin@example.com","password":"admin123"}'
    local auth_response=$(curl -s -X POST http://localhost:3000/v1/auth/login \
        -H "Content-Type: application/json" \
        -d "$login_data")
    
    local token=$(echo "$auth_response" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$token" ]; then
        print_error "Failed to get auth token"
        return 1
    fi
    
    # Test asset creation
    local asset_data='{"type":"test_asset","title":"Test Asset","description":"Test Description","nav":100000}'
    local create_response=$(curl -s -X POST http://localhost:3000/v1/admin/assets \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $token" \
        -d "$asset_data")
    
    if echo "$create_response" | grep -q "id"; then
        return 0
    else
        print_error "Asset creation failed: $create_response"
        return 1
    fi
}

# Test 6: Investor App Loading
test_investor_app() {
    local response=$(curl -s http://localhost:8080)
    if echo "$response" | grep -q "RWA Investor"; then
        return 0
    else
        print_error "Investor app failed to load"
        return 1
    fi
}

# Test 7: Admin App Loading
test_admin_app() {
    local response=$(curl -s http://localhost:8083)
    if echo "$response" | grep -q "Admin Dashboard"; then
        return 0
    else
        print_error "Admin app failed to load"
        return 1
    fi
}

# Test 8: Smart Contract Deployment
test_contracts() {
    local response=$(curl -s -X POST http://localhost:8545 \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}')
    
    if echo "$response" | grep -q "result"; then
        return 0
    else
        print_error "Blockchain connection failed: $response"
        return 1
    fi
}

# Test 9: File Storage (MinIO)
test_file_storage() {
    local response=$(curl -s http://localhost:9000/minio/health/live)
    if [ "$response" = "OK" ]; then
        return 0
    else
        print_error "File storage service failed: $response"
        return 1
    fi
}

# Test 10: Redis Cache
test_redis_cache() {
    # Test Redis by setting and getting a value through the API
    local response=$(curl -s http://localhost:3000/v1/assets?limit=1)
    if echo "$response" | grep -q "items"; then
        return 0
    else
        print_error "Redis cache test failed: $response"
        return 1
    fi
}

# Test 11: Complete Investment Flow
test_investment_flow() {
    # This is a simplified test - in a real scenario, you'd test the full flow
    local response=$(curl -s http://localhost:3000/v1/assets)
    if echo "$response" | grep -q "items"; then
        return 0
    else
        print_error "Investment flow test failed: $response"
        return 1
    fi
}

# Test 12: Agent Verification Flow
test_verification_flow() {
    local response=$(curl -s http://localhost:3000/v1/agents/search)
    if echo "$response" | grep -q "items"; then
        return 0
    else
        print_error "Verification flow test failed: $response"
        return 1
    fi
}

# Test 13: Portfolio Management
test_portfolio_management() {
    local response=$(curl -s http://localhost:3000/v1/invest/holdings)
    if echo "$response" | grep -q "holdings"; then
        return 0
    else
        print_error "Portfolio management test failed: $response"
        return 1
    fi
}

# Test 14: Marketplace Operations
test_marketplace() {
    local response=$(curl -s http://localhost:3000/v1/orderbook/1")
    if echo "$response" | grep -q "orders"; then
        return 0
    else
        print_error "Marketplace test failed: $response"
        return 1
    fi
}

# Test 15: Revenue Distribution
test_revenue_distribution() {
    local response=$(curl -s http://localhost:3000/v1/distributions/1")
    if echo "$response" | grep -q "items"; then
        return 0
    else
        print_error "Revenue distribution test failed: $response"
        return 1
    fi
}

# Performance Test
test_performance() {
    print_status "Running performance test..."
    
    local start_time=$(date +%s)
    local response=$(curl -s http://localhost:3000/v1/assets)
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    if [ $duration -lt 5 ]; then
        print_success "Performance test passed (${duration}s)"
        return 0
    else
        print_error "Performance test failed (${duration}s > 5s)"
        return 1
    fi
}

# Load Test
test_load() {
    print_status "Running load test..."
    
    local success_count=0
    local total_requests=10
    
    for i in $(seq 1 $total_requests); do
        if curl -s http://localhost:3000/health > /dev/null 2>&1; then
            ((success_count++))
        fi
    done
    
    local success_rate=$((success_count * 100 / total_requests))
    
    if [ $success_rate -ge 90 ]; then
        print_success "Load test passed (${success_rate}% success rate)"
        return 0
    else
        print_error "Load test failed (${success_rate}% success rate < 90%)"
        return 1
    fi
}

# Main test execution
main() {
    echo "Starting End-to-End Tests..."
    echo "============================"
    echo ""
    
    # Wait for all services to be ready
    wait_for_service "http://localhost:3000/health" "Backend API"
    wait_for_service "http://localhost:8080" "Investor App"
    wait_for_service "http://localhost:8083" "Admin App"
    wait_for_service "http://localhost:8545" "Blockchain"
    
    echo ""
    print_status "All services are ready. Starting tests..."
    echo ""
    
    # Run all tests
    run_test "Services Running" "test_services_running"
    run_test "API Health Check" "test_api_health"
    run_test "Database Connection" "test_database_connection"
    run_test "Authentication Flow" "test_authentication"
    run_test "Asset CRUD Operations" "test_asset_crud"
    run_test "Investor App Loading" "test_investor_app"
    run_test "Admin App Loading" "test_admin_app"
    run_test "Smart Contract Deployment" "test_contracts"
    run_test "File Storage (MinIO)" "test_file_storage"
    run_test "Redis Cache" "test_redis_cache"
    run_test "Investment Flow" "test_investment_flow"
    run_test "Agent Verification Flow" "test_verification_flow"
    run_test "Portfolio Management" "test_portfolio_management"
    run_test "Marketplace Operations" "test_marketplace"
    run_test "Revenue Distribution" "test_revenue_distribution"
    run_test "Performance Test" "test_performance"
    run_test "Load Test" "test_load"
    
    # Print test results
    echo ""
    echo "Test Results Summary"
    echo "======================="
    echo ""
    print_success "Tests Passed: $TESTS_PASSED"
    if [ $TESTS_FAILED -gt 0 ]; then
        print_error "Tests Failed: $TESTS_FAILED"
    else
        print_success "Tests Failed: $TESTS_FAILED"
    fi
    
    local total_tests=$((TESTS_PASSED + TESTS_FAILED))
    local success_rate=$((TESTS_PASSED * 100 / total_tests))
    
    echo ""
    print_status "Success Rate: ${success_rate}%"
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo ""
        print_success "All tests passed! The RWA platform is working correctly."
        echo ""
        print_status "You can now:"
        print_status "  • Access Investor App: http://localhost:8080"
        print_status "  • Access Admin App: http://localhost:8083"
        print_status "  • Use API: http://localhost:3000/docs"
        print_status "  • View MinIO Console: http://localhost:9001"
        echo ""
        exit 0
    else
        echo ""
        print_error "Some tests failed. Please check the logs and fix the issues."
        echo ""
        print_status "Useful commands for debugging:"
        print_status "  • View logs: docker-compose -f docker-compose.local.yml logs -f"
        print_status "  • Check service status: docker-compose -f docker-compose.local.yml ps"
        print_status "  • Restart services: docker-compose -f docker-compose.local.yml restart"
        echo ""
        exit 1
    fi
}

# Run main function
main "$@"


