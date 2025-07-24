# Ginger Server Setup Instructions

## 🚀 Quick Setup

### 1. Install Dependencies
```bash
cd ginger_server
npm install
```

### 2. Configure Environment
Edit the `.env` file and update these values:

```env
# Database Configuration - UPDATE THESE!
DB_HOST=localhost
DB_PORT=5432
DB_NAME=ginger_db
DB_USER=ginger_prod_user
DB_PASSWORD=your_actual_database_password

# JWT Secret - CHANGE THIS!
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
```

### 3. Database Setup
Make sure your PostgreSQL database is running and the `ginger_db` database exists with the schema from `ginger_library/DB_Schema.sql`.

### 4. Start Server
```bash
# Development mode (with auto-restart)
npm run dev

# Production mode
npm start
```

## 📡 API Endpoints Created

All endpoints follow your project rules:
- ✅ All routes use POST method
- ✅ All responses include `return_code`
- ✅ Uses bcrypt for password hashing
- ✅ JWT authentication
- ✅ Database integration

### Authentication Endpoints:

1. **POST** `/auth/register` - Register new user
2. **POST** `/auth/login` - Login user
3. **POST** `/auth/validate` - Validate auth token
4. **POST** `/auth/logout` - Logout user

## 🔧 Configuration Details

### Database Connection
- Uses connection pooling for performance
- Automatic reconnection on failure
- Query logging in development mode

### Security Features
- Bcrypt password hashing (12 rounds)
- JWT tokens with 7-day expiration
- Secure token storage in database
- Input validation and sanitization

### Error Handling
- Consistent error response format
- Detailed logging for debugging
- Graceful error recovery

## 🧪 Testing

### Test with curl:

**Register:**
```bash
curl -X POST http://192.168.1.108:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "display_name": "Test User"
  }'
```

**Login:**
```bash
curl -X POST http://192.168.1.108:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

## 🔍 Troubleshooting

### Common Issues:

1. **Database connection failed**
   - Check PostgreSQL is running
   - Verify database credentials in `.env`
   - Ensure database exists

2. **Port already in use**
   - Change PORT in `.env` file
   - Kill existing process: `lsof -ti:3000 | xargs kill`

3. **JWT errors**
   - Make sure JWT_SECRET is set in `.env`
   - Check token format in requests

### Logs
- Server logs show all requests and database queries
- Check console output for detailed error messages
- Database connection status shown on startup

## 📱 Flutter Integration

Your Flutter app is already configured to work with these endpoints:
- API base URL: `http://192.168.1.108:3000`
- All authentication flows implemented
- Secure token storage on device
- Automatic token validation on app start

## 🔐 Security Notes

**For Production:**
1. Change JWT_SECRET to a strong random key
2. Use HTTPS instead of HTTP
3. Set up proper database user permissions
4. Enable rate limiting
5. Add request logging and monitoring
