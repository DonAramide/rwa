#!/bin/bash

# RWA Backend Setup Script
echo "🚀 Setting up RWA Backend..."

# Check if PostgreSQL is running
if ! pg_isready -h localhost -p 5432 > /dev/null 2>&1; then
    echo "❌ PostgreSQL is not running. Please start PostgreSQL first."
    echo "   macOS: brew services start postgresql"
    echo "   Linux: sudo systemctl start postgresql"
    exit 1
fi

# Create database if it doesn't exist
echo "📦 Setting up database..."
createdb rwa 2>/dev/null || echo "Database 'rwa' already exists"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Run migrations
echo "🗄️  Running database migrations..."
npm run migration:run

echo "✅ Backend setup complete!"
echo ""
echo "🎯 Next steps:"
echo "   1. Start the server: npm run start:api"
echo "   2. Visit API docs: http://localhost:3000/api/docs"
echo "   3. Default admin login:"
echo "      Email: admin@rwa-platform.com"
echo "      Password: admin123"
echo ""