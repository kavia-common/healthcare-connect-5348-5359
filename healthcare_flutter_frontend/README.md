# Healthcare Connect Flutter Frontend

Flutter mobile application for the Healthcare Connect healthcare platform.

## Overview

A responsive Flutter application that provides patients and doctors with access to healthcare services including:

- User registration and authentication
- Patient dashboard and profile management
- Doctor dashboard and profile management
- Consultation scheduling and viewing
- Medical records access
- Doctor search and discovery

## Features

### For Patients
- **Registration & Login:** Secure authentication with JWT tokens
- **Dashboard:** Overview of upcoming consultations and quick actions
- **Profile Management:** Update personal information (age, gender, address)
- **Consultations:** View scheduled and past consultations
- **Medical Records:** Access personal medical history
- **Find Doctors:** Browse available doctors by specialty

### For Doctors
- **Registration & Login:** Secure authentication with role-based access
- **Dashboard:** Overview of upcoming consultations
- **Profile Management:** Update specialty and bio
- **Consultations:** View and manage patient consultations
- **Patient List:** Browse registered patients
- **Medical Records:** View and manage patient records

### For Admins
- Full administrative access to all resources
- User management
- System monitoring

## Tech Stack

- **Framework:** Flutter 3.7+
- **State Management:** Provider
- **HTTP Client:** http package
- **Storage:** shared_preferences (secure storage for tokens)
- **Environment:** flutter_dotenv
- **UI:** Material Design 3 with custom minimalist theme

## Prerequisites

- Flutter SDK 3.7.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / Xcode (for mobile development)
  - **Android NDK 27.0.12077973** (configured in `android/app/build.gradle.kts`)
- Chrome (for web development)
- Backend API running at configured URL

## Installation

### 1. Install Flutter

Follow the official Flutter installation guide:
https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter doctor
```

**Android Development Requirements:**
- Android NDK 27.0.12077973 is configured in `android/app/build.gradle.kts`
- This NDK version will be automatically downloaded by Android Studio/Gradle when building the app
- No manual NDK installation is required if using Android Studio

### 2. Clone or Navigate to Project

```bash
cd healthcare-connect-5348-5359/healthcare_flutter_frontend
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Set Up Environment Variables

Create a `.env` file in the project root:

```bash
BACKEND_BASE_URL=http://localhost:3001
```

**Important:** For Android emulator, use `http://10.0.2.2:3001` instead of `localhost:3001`

### 5. Verify Setup

```bash
flutter doctor -v
```

## Environment Configuration

### Development (.env)

```bash
# For iOS Simulator or Flutter Web
BACKEND_BASE_URL=http://localhost:3001

# For Android Emulator (IMPORTANT!)
BACKEND_BASE_URL=http://10.0.2.2:3001
```

### Network Address Guide

Flutter apps need different network addresses depending on the platform:

| Platform | Backend URL | Notes |
|----------|-------------|-------|
| **iOS Simulator** | http://localhost:3001 | Direct access to host |
| **Android Emulator** | http://10.0.2.2:3001 | 10.0.2.2 maps to host's localhost |
| **Flutter Web** | http://localhost:3001 | Same network as browser |
| **Physical Device** | http://YOUR_IP:3001 | Use host machine's IP address |

To find your host IP (for physical devices):
```bash
# macOS/Linux
ifconfig | grep "inet "

# Windows
ipconfig
```

## Running the Application

### Run on iOS Simulator

```bash
flutter run -d iPhone
```

### Run on Android Emulator

1. Start Android emulator from Android Studio
2. Or use command line:
   ```bash
   flutter emulators --launch <emulator_id>
   ```
3. Run app:
   ```bash
   flutter run -d emulator-5554
   ```

### Run on Chrome (Web)

```bash
flutter run -d chrome
```

### Run on Physical Device

1. Enable developer mode on device
2. Connect via USB
3. Run:
   ```bash
   flutter run
   ```

### Hot Reload

While the app is running, press `r` in the terminal to hot reload changes.

## Demo Credentials

Use these credentials to test the application:

### Patient Accounts
1. **John Smith**
   - Email: `patient1@healthcare.com`
   - Password: `patient123`

2. **Emma Davis**
   - Email: `patient2@healthcare.com`
   - Password: `patient123`

### Doctor Accounts
1. **Dr. Sarah Johnson** (Cardiology)
   - Email: `doctor1@healthcare.com`
   - Password: `doctor123`

2. **Dr. Michael Chen** (Pediatrics)
   - Email: `doctor2@healthcare.com`
   - Password: `doctor123`

### Admin Account
- Email: `admin@healthcare.com`
- Password: `admin123`

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── models/                      # Data models
│   ├── user.dart
│   ├── patient.dart
│   ├── doctor.dart
│   ├── consultation.dart
│   └── medical_record.dart
├── providers/                   # State management
│   └── auth_provider.dart
├── screens/                     # UI screens
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── patient/
│   │   ├── patient_dashboard.dart
│   │   ├── patient_profile_screen.dart
│   │   ├── consultations_screen.dart
│   │   └── medical_records_screen.dart
│   ├── doctor/
│   │   ├── doctor_dashboard.dart
│   │   ├── doctor_profile_screen.dart
│   │   ├── doctor_consultations_screen.dart
│   │   └── patients_list_screen.dart
│   └── common/
│       └── doctors_list_screen.dart
├── services/                    # API and business logic
│   ├── api_service.dart
│   └── auth_service.dart
├── utils/                       # Utilities
│   ├── constants.dart
│   └── theme.dart
└── widgets/                     # Reusable widgets
    ├── consultation_card.dart
    ├── doctor_card.dart
    └── medical_record_card.dart
```

## Available Screens

### Authentication Screens
- **Login Screen:** User authentication
- **Register Screen:** New user registration with role selection

### Patient Screens
- **Patient Dashboard:** Home screen with quick actions
- **Profile Screen:** View and edit patient information
- **Consultations Screen:** List of scheduled consultations
- **Medical Records Screen:** Access medical history
- **Find Doctors Screen:** Browse and search doctors

### Doctor Screens
- **Doctor Dashboard:** Home screen with patient overview
- **Profile Screen:** View and edit doctor information
- **Consultations Screen:** Manage patient consultations
- **Patients List Screen:** View all registered patients

## Design & Theming

### Minimalist Pure White Theme

The app uses a clean, minimalist design with:

- **Primary Color:** #374151 (Gray-700)
- **Secondary Color:** #9CA3AF (Gray-400)
- **Success Color:** #10B981 (Green)
- **Error Color:** #EF4444 (Red)
- **Background:** #FFFFFF (Pure White)
- **Surface:** #F9FAFB (Light Gray)

### Key Design Principles
- Generous whitespace
- Simple typography
- Subtle design elements
- Clean lines and minimal distractions
- Focus on content and usability

## Building for Production

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS IPA

```bash
flutter build ios --release
```

Then archive in Xcode.

### Web

```bash
flutter build web
```

Output: `build/web/`

## Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter drive --target=test_driver/app.dart
```

## Troubleshooting

### Common Issues

#### 1. Network Connection Failed (Android Emulator)

**Symptoms:**
- "Connection refused" or "Failed to connect to backend"
- HTTP errors when logging in

**Solutions:**
- **Use correct network address:** `http://10.0.2.2:3001` for Android emulator
- Update `.env`:
  ```bash
  BACKEND_BASE_URL=http://10.0.2.2:3001
  ```
- Restart app after changing `.env`
- Verify backend is running: `curl http://localhost:3001`

#### 2. 401 Unauthorized Errors

**Symptoms:**
- Login succeeds but subsequent requests fail
- "Could not validate credentials" error

**Solutions:**
- Token may have expired (default: 60 minutes)
- Logout and login again
- Check system time is synchronized
- Verify JWT_SECRET matches between frontend and backend

#### 3. CORS Errors (Flutter Web)

**Symptoms:**
- Browser console shows CORS policy errors
- Requests blocked by browser

**Solutions:**
- Add `http://localhost:3000` or your web URL to backend CORS_ORIGINS
- Backend `.env` should include:
  ```bash
  CORS_ORIGINS=http://localhost:3000,http://localhost:3001
  ```
- Restart backend after changing CORS settings

#### 4. White Screen or App Crashes

**Symptoms:**
- App shows blank white screen
- App crashes on startup

**Solutions:**
- Check `.env` file exists and is properly formatted
- Run `flutter clean` and `flutter pub get`
- Check console for error messages: `flutter logs`
- Verify all dependencies installed: `flutter pub get`

#### 5. Can't Find Backend (.env not loading)

**Symptoms:**
- App tries to connect to wrong URL
- "BACKEND_BASE_URL not found" error

**Solutions:**
- Ensure `.env` file is in project root (same level as `pubspec.yaml`)
- Verify `.env` is listed in `pubspec.yaml` under assets:
  ```yaml
  flutter:
    assets:
      - .env
  ```
- Run `flutter clean` and rebuild
- Check file permissions: `.env` should be readable

#### 6. "Gradle build failed" (Android)

**Symptoms:**
- Build errors mentioning Gradle
- "Execution failed for task ':app:compileDebugKotlin'"

**Solutions:**
- Update Android Gradle Plugin version
- Clear Gradle cache:
  ```bash
  cd android && ./gradlew clean
  ```
- Invalidate caches in Android Studio
- Ensure Java 11+ installed

#### 7. iOS Simulator Not Connecting

**Symptoms:**
- iOS simulator can't reach backend
- Timeout errors on iOS

**Solutions:**
- For iOS simulator, use `http://localhost:3001` (not 10.0.2.2)
- Check firewall isn't blocking connections
- Verify backend is accessible: `curl http://localhost:3001`

### Debugging Tips

1. **Enable Verbose Logging:**
   ```bash
   flutter run -v
   ```

2. **Check Device Logs:**
   ```bash
   flutter logs
   ```

3. **Test Backend Connection:**
   ```bash
   # From emulator/simulator
   curl http://10.0.2.2:3001  # Android
   curl http://localhost:3001  # iOS
   ```

4. **Verify .env Loading:**
   Add debug print in `main.dart`:
   ```dart
   print('Backend URL: ${dotenv.env['BACKEND_BASE_URL']}');
   ```

5. **Check Network Permissions:**
   - Android: `android/app/src/main/AndroidManifest.xml` should have `<uses-permission android:name="android.permission.INTERNET"/>`
   - iOS: No special permission needed for HTTP to localhost

### Performance Optimization

- Use `const` constructors where possible
- Implement proper image caching
- Lazy load lists with large data
- Minimize rebuilds with proper Provider usage

## Deployment

### Android Play Store

1. Create signed APK/AAB
2. Update version in `pubspec.yaml`
3. Follow Play Store submission guidelines

### iOS App Store

1. Archive in Xcode
2. Update version in `pubspec.yaml` and `ios/Runner.xcodeproj`
3. Follow App Store submission guidelines

### Web Hosting

1. Build: `flutter build web`
2. Deploy `build/web` to hosting service (Firebase Hosting, Netlify, etc.)
3. Update `BACKEND_BASE_URL` to production API URL

## Development Tips

### Hot Reload vs Hot Restart

- **Hot Reload (r):** Preserves app state, faster
- **Hot Restart (R):** Resets app state, slower but more thorough
- **Full Restart:** Stop and run again if hot restart doesn't work

### State Management

The app uses Provider for state management:
- `AuthProvider`: Handles authentication state
- Add more providers as needed for feature-specific state

### Adding New Features

1. Create model in `models/`
2. Add API calls in `services/`
3. Create screens in appropriate `screens/` subfolder
4. Add navigation in dashboard
5. Update README with new features

## Contributing

1. Follow Flutter style guide
2. Use meaningful variable names
3. Add comments for complex logic
4. Test on both iOS and Android
5. Update documentation for new features

## Resources

- **Flutter Documentation:** https://docs.flutter.dev/
- **Provider Package:** https://pub.dev/packages/provider
- **Material Design 3:** https://m3.material.io/
- **Dart Language:** https://dart.dev/

## License

[Your License Here]

## Support

For issues or questions:
- Check troubleshooting section above
- Review Flutter documentation
- Test with demo credentials provided
- Verify backend is running and accessible
