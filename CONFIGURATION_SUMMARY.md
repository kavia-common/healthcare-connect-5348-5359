# Cross-Container Configuration Summary

This document summarizes the configuration changes made to ensure proper integration between the Flutter frontend, FastAPI backend, and MongoDB database containers.

## Changes Made

### 1. Frontend Configuration (Flutter)

**File:** `healthcare-connect-5348-5359/healthcare_flutter_frontend/.env`

**Content:**
```bash
BACKEND_BASE_URL=http://localhost:3001
```

**Note:** For Android emulator testing, developers should change this to `http://10.0.2.2:3001`

### 2. Backend Configuration (FastAPI)

**File:** `healthcare-connect-5348-5357/healthcare_backend_api/.env`

**Updated Configuration:**
```bash
MONGO_URI=mongodb://appuser:dbuser123@localhost:5001/myapp?authSource=admin
MONGO_DB=myapp
JWT_SECRET=your-secret-key-change-in-production-use-secure-random-string
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRES_MINUTES=60
CORS_ORIGINS=http://localhost:3000,http://localhost:3001
BACKEND_BASE_URL=http://localhost:3001
JWT_CLOCK_SKEW_SECONDS=30
```

**Key Changes:**
- Updated `MONGO_URI` to match database credentials (appuser/dbuser123)
- Updated port from 27017 to 5001 (actual database port)
- Updated database name to `myapp` (matches database setup)
- Ensured `CORS_ORIGINS` includes both ports 3000 and 3001
- Set `BACKEND_BASE_URL` to port 3001

### 3. Backend .env.example Template

**File:** `healthcare-connect-5348-5357/healthcare_backend_api/.env.example`

**Updated** to reflect correct configuration with comments about demo credentials and security.

### 4. CORS Configuration (Backend)

**File:** `healthcare-connect-5348-5357/healthcare_backend_api/src/api/main.py`

**Status:** Already properly configured
- CORS middleware correctly reads from `CORS_ORIGINS` environment variable
- Automatically includes common development origins
- Supports both ports 3000 and 3001

### 5. Database README

**File:** `healthcare-connect-5348-5358/healthcare_database/README.md` (NEW)

**Contents:**
- Complete schema documentation for all collections
- Database connection information
- Demo credentials for testing
- Setup and verification instructions
- Troubleshooting guide
- Security notes

### 6. Backend README

**File:** `healthcare-connect-5348-5357/healthcare_backend_api/README.md` (UPDATED)

**Enhanced with:**
- Complete setup instructions
- Demo credentials section
- Demo authentication flow with curl examples
- Comprehensive troubleshooting section
- CORS configuration details
- Network configuration for emulators
- Security best practices

### 7. Frontend README

**File:** `healthcare-connect-5348-5359/healthcare_flutter_frontend/README.md` (UPDATED)

**Enhanced with:**
- Complete environment setup guide
- Network address guide for different platforms
- Demo credentials section
- Detailed screen documentation
- Comprehensive troubleshooting section
- Android emulator network notes (10.0.2.2)
- Building and deployment instructions

## Database Connection Details

**Connection String:**
```
mongodb://appuser:dbuser123@localhost:5001/myapp?authSource=admin
```

**Parameters:**
- Host: localhost
- Port: 5001
- Database: myapp
- Username: appuser
- Password: dbuser123
- Auth Source: admin

## Demo Credentials

### Admin Account
- Email: admin@healthcare.com
- Password: admin123

### Doctor Accounts
1. doctor1@healthcare.com / doctor123 (Cardiology)
2. doctor2@healthcare.com / doctor123 (Pediatrics)

### Patient Accounts
1. patient1@healthcare.com / patient123
2. patient2@healthcare.com / patient123

## CORS Configuration

The backend accepts requests from:
- http://localhost:3000
- http://localhost:3001
- http://127.0.0.1:3000
- http://127.0.0.1:5173
- https://appetize.io

Additional origins are automatically included by the backend's CORS middleware.

## Network Configuration Notes

### Flutter Mobile Development

**Android Emulator:**
- Use `BACKEND_BASE_URL=http://10.0.2.2:3001`
- The Android emulator maps 10.0.2.2 to the host's localhost

**iOS Simulator:**
- Use `BACKEND_BASE_URL=http://localhost:3001`
- iOS simulator can directly access host's localhost

**Flutter Web:**
- Use `BACKEND_BASE_URL=http://localhost:3001`
- Runs in browser on same network

**Physical Devices:**
- Use `BACKEND_BASE_URL=http://<HOST_IP>:3001`
- Replace <HOST_IP> with your computer's IP address

## Troubleshooting Common Issues

### 1. CORS Errors
**Symptom:** Browser shows CORS policy errors

**Solution:**
- Verify backend `CORS_ORIGINS` includes frontend URL
- Restart backend after changing CORS settings
- For Flutter web, ensure http://localhost:3000 or :3001 is in CORS_ORIGINS

### 2. 401 Unauthorized
**Symptom:** Login works but subsequent requests fail

**Solution:**
- Token may have expired (60 minute default)
- Ensure Authorization header is included: `Authorization: Bearer <token>`
- Logout and login again to get fresh token

### 3. Network Connection Failed (Android)
**Symptom:** Flutter app can't reach backend on Android emulator

**Solution:**
- Change `.env` to use `http://10.0.2.2:3001` instead of localhost
- Verify backend is running: `curl http://localhost:3001`
- Restart Flutter app after changing .env

### 4. Database Connection Failed
**Symptom:** Backend can't connect to MongoDB

**Solution:**
- Verify MongoDB is running: `docker ps | grep mongodb`
- Check connection string uses correct credentials
- Test connection: `mongosh mongodb://appuser:dbuser123@localhost:5001/myapp?authSource=admin`

## Minimal Code Changes

**No code changes were required** as the existing codebase already had proper CORS configuration. The changes were limited to:

1. Environment files (.env and .env.example)
2. Documentation (README files)
3. Configuration alignment

The backend's CORS implementation already supports the necessary origins through the environment variable configuration.

## Verification Steps

### 1. Verify Backend Configuration
```bash
cd healthcare-connect-5348-5357/healthcare_backend_api
cat .env  # Check MONGO_URI, CORS_ORIGINS
```

### 2. Verify Database Connection
```bash
mongosh mongodb://appuser:dbuser123@localhost:5001/myapp?authSource=admin --eval "db.stats()"
```

### 3. Verify Frontend Configuration
```bash
cd healthcare-connect-5348-5359/healthcare_flutter_frontend
cat .env  # Check BACKEND_BASE_URL
```

### 4. Test Backend API
```bash
curl http://localhost:3001
# Should return: {"message":"Healthy"}
```

### 5. Test Authentication Flow
```bash
curl -X POST http://localhost:3001/auth/login_json \
  -H "Content-Type: application/json" \
  -d '{"email":"patient1@healthcare.com","password":"patient123"}'
# Should return access token
```

## Documentation Locations

- **Database README:** `healthcare-connect-5348-5358/healthcare_database/README.md`
- **Backend README:** `healthcare-connect-5348-5357/healthcare_backend_api/README.md`
- **Frontend README:** `healthcare-connect-5348-5359/healthcare_flutter_frontend/README.md`
- **Backend API Docs:** http://localhost:3001/docs (when running)

## Next Steps

1. Review all README files for accuracy
2. Test the complete authentication flow
3. Verify cross-container communication
4. Test on different platforms (iOS, Android, Web)
5. Update any environment-specific configurations for deployment

## Security Reminders

⚠️ **For Production Deployment:**

1. Generate secure JWT_SECRET: `python -c "import secrets; print(secrets.token_urlsafe(32))"`
2. Use strong database passwords
3. Enable MongoDB authentication and TLS
4. Restrict CORS_ORIGINS to production domains only
5. Use HTTPS for all communications
6. Implement rate limiting
7. Regular security audits and updates
