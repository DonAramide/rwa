# RWA Platform Backend (Enhanced)

A comprehensive NestJS backend for the Real World Assets tokenization platform with admin dashboard, authentication, and full API management.

## 🚀 Quick Start

### Prerequisites
- Node.js 18+ 
- PostgreSQL 14+
- npm or yarn

### Setup & Installation

1. **Quick Setup** (recommended):
```bash
cd backend/nest
./scripts/setup.sh
```

2. **Manual Setup**:
```bash
# Install dependencies
npm install

# Create database
createdb rwa

# Run migrations
npm run migration:run

# Start development server
npm run start:api
```

### Default Admin Access
- **Email**: `admin@rwa-platform.com`
- **Password**: `admin123`

## 🏗️ Architecture

### Enhanced Features
- ✅ **Role-based Authentication** (Admin, User, Agent, Issuer)
- ✅ **Comprehensive Admin Dashboard** with real-time stats
- ✅ **JWT Security** with role guards and validation
- ✅ **Swagger API Documentation** 
- ✅ **TypeORM Entities** with proper relationships
- ✅ **Input Validation** with class-validator
- ✅ **Password Security** with bcrypt
- ✅ **CORS Configuration** for Flutter web
- ✅ **Error Handling** and logging
- ✅ **Database Migrations** with TypeORM

### API Endpoints

#### Authentication (`/v1/auth`)
- `POST /login` - User login
- `POST /admin/login` - Admin-only login
- `POST /register` - User registration  
- `GET /me` - Get current user profile
- `PATCH /change-password` - Change password
- `PATCH /users/:id/kyc` - Update user KYC (Admin only)

#### Admin Dashboard (`/v1/admin`)
- `GET /dashboard/stats` - Dashboard statistics
- `GET /dashboard/activity` - Recent activity feed
- `GET /users` - Users list with filtering
- `POST /distributions/trigger` - Trigger payouts
- `POST /assets/:id/verify` - Approve/reject assets

#### Assets (`/v1/assets`)
- Asset CRUD operations
- Verification workflows
- Portfolio management

#### Agents (`/v1/agents`)
- Agent marketplace
- Verification job management  
- Agent reviews and ratings

#### Revenue (`/v1/revenue`)
- Distribution management
- Payout processing
- Financial reporting

## 🗄️ Database Schema

### Enhanced User Entity
```sql
users (
  id, email, first_name, last_name, 
  password_hash, role, status, kyc_status,
  residency, kyc_notes, risk_flags,
  last_login_at, last_login_ip, 
  two_factor_enabled, created_at, updated_at
)
```

### User Roles
- `admin` - Platform administrators
- `user` - Regular investors  
- `agent` - Verification agents
- `issuer` - Asset issuers

### User Status
- `active` - Can use platform
- `suspended` - Temporarily blocked
- `inactive` - Account disabled

## 🛡️ Security Features

### Authentication & Authorization
- JWT tokens with 24h expiry
- Role-based access control (RBAC)
- Password hashing with bcrypt (12 rounds)
- Input validation and sanitization
- CORS protection

### Admin Security
- Separate admin login endpoint
- Role validation guards
- Audit logging capabilities
- Secure password requirements

## 📚 API Documentation

Once running, visit:
- **Swagger UI**: `http://localhost:3000/api/docs`
- **API Base**: `http://localhost:3000/v1`

## 🧪 Development

### Available Scripts
```bash
npm run start:api          # Start development server
npm run migration:generate # Generate new migration
npm run migration:run      # Run pending migrations
npm run migration:revert   # Revert last migration
```

### Database Operations
```bash
# Generate migration for entity changes
npm run migration:generate

# Apply migrations
npm run migration:run

# Connect to database
psql -d rwa
```

### Environment Variables
Create `.env` file:
```env
DATABASE_URL=postgresql://username:password@localhost:5432/rwa
JWT_SECRET=your-super-secure-jwt-secret-key
PORT=3000
NODE_ENV=development
```

## 🔧 Configuration

### TypeORM Configuration
- Database: PostgreSQL with TypeORM
- Migrations: Automatic schema management
- Entities: Strongly typed with decorators

### Validation
- Global validation pipes
- DTO-based request validation
- Custom validators for business logic

### Logging & Monitoring
- Structured logging
- Error handling middleware
- Health check endpoint

## 🚀 Production Deployment

### Requirements
- PostgreSQL 14+ database
- Redis for caching (optional)
- SSL certificate for HTTPS
- Environment variables configured

### Security Checklist
- [ ] Change default admin password
- [ ] Set strong JWT secret
- [ ] Configure CORS properly
- [ ] Enable rate limiting
- [ ] Set up SSL/TLS
- [ ] Configure logging
- [ ] Set up monitoring

## 📊 Admin Dashboard Features

### Real-time Statistics
- Total users and KYC status
- Asset counts and values
- Agent approvals and ratings
- Portfolio value tracking
- Monthly payout totals

### Management Capabilities
- User KYC approval/rejection
- Asset verification workflow
- Agent status management
- Revenue distribution triggers
- Activity monitoring

### Filtering & Search
- User filtering by role/status/KYC
- Asset filtering by type/status
- Agent filtering by region/rating
- Pagination for large datasets

## 🤝 Integration

### Flutter Admin App
The backend is designed to work seamlessly with the Flutter admin dashboard:

```dart
// API Client configuration
const String baseUrl = 'http://localhost:3000/v1';

// Authentication
POST /auth/admin/login
GET /admin/dashboard/stats
GET /admin/dashboard/activity
```

### Frontend Integration
- RESTful API design
- JSON responses
- JWT token authentication
- CORS enabled for web clients

## 📈 Performance

### Optimizations
- Database indexes on frequently queried fields
- Connection pooling with TypeORM
- Efficient query patterns
- Pagination for large datasets

### Monitoring
- Health check endpoint: `/health`
- Database connection monitoring
- API response time tracking

## 🐛 Troubleshooting

### Common Issues

**Database Connection Issues**:
```bash
# Check PostgreSQL status
pg_isready -h localhost -p 5432

# Start PostgreSQL
brew services start postgresql  # macOS
sudo systemctl start postgresql # Linux
```

**Migration Issues**:
```bash
# Check migration status
npm run typeorm migration:show

# Revert problematic migration
npm run migration:revert
```

**Authentication Issues**:
- Verify JWT secret is set
- Check token expiry (24h default)
- Ensure admin user exists in database

## 📝 API Usage Examples

### Admin Login
```bash
curl -X POST http://localhost:3000/v1/auth/admin/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@rwa-platform.com","password":"admin123"}'
```

### Get Dashboard Stats
```bash
curl -X GET http://localhost:3000/v1/admin/dashboard/stats \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Create User
```bash
curl -X POST http://localhost:3000/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"SecurePass123!","firstName":"John","lastName":"Doe"}'
```

---

## 🎯 Next Steps

The backend is now production-ready with:
- ✅ Enhanced authentication system
- ✅ Comprehensive admin dashboard APIs  
- ✅ Role-based security
- ✅ Database migrations
- ✅ API documentation
- ✅ Development tools

Ready to integrate with your Flutter admin dashboard and extend with additional features as needed!