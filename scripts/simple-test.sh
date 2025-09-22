#!/bin/bash

# Simple RWA Platform Test Script
echo "Testing RWA Platform Local Deployment..."

# Test services
echo "Testing services..."

# Test PostgreSQL
if docker-compose -f docker-compose.local.yml exec postgres pg_isready -U rwa_user > /dev/null 2>&1; then
    echo "✅ PostgreSQL: Running"
else
    echo "❌ PostgreSQL: Not responding"
fi

# Test Redis
if docker-compose -f docker-compose.local.yml exec redis redis-cli ping > /dev/null 2>&1; then
    echo "✅ Redis: Running"
else
    echo "❌ Redis: Not responding"
fi

# Test MinIO
if curl -s http://localhost:9000/minio/health/live > /dev/null 2>&1; then
    echo "✅ MinIO: Running"
else
    echo "❌ MinIO: Not responding"
fi

# Test Investor App
if curl -s -o /dev/null -w '%{http_code}' http://localhost:8080 | grep -q "200"; then
    echo "✅ Investor App: Running"
else
    echo "❌ Investor App: Not responding"
fi

# Test Admin App
if curl -s -o /dev/null -w '%{http_code}' http://localhost:8083 | grep -q "200"; then
    echo "✅ Admin App: Running"
else
    echo "❌ Admin App: Not responding"
fi

# Test Backend API
if curl -s -o /dev/null -w '%{http_code}' http://localhost:3000/v1/assets | grep -q "200"; then
    echo "✅ Backend API: Running"
else
    echo "❌ Backend API: Not responding"
fi

echo ""
echo "Test completed!"


