# Healthcare Connect Flutter Frontend

A minimalist Pure White Flutter app for Healthcare Connect. Implements authentication, doctors, appointments, medical records, and profile, using Riverpod for state management and Dio for networking.

## Features

- Minimalist "Pure White" theme with subtle grays and clean typography
- Authentication (login/register) using `/auth` endpoints
- Secure JWT storage using `flutter_secure_storage`
- Route protection with `go_router` and Riverpod
- Bottom navigation tabs:
  - Dashboard
  - Doctors
  - Appointments
  - Records
  - Profile
- API Client using Dio, reads `BASE_URL` from `.env` (with `.env.example` fallback)
- Repositories & Providers per feature
- Simple, responsive layouts

## Requirements

- Flutter SDK
- A running FastAPI backend providing endpoints:
  - `POST /auth/login`
  - `POST /auth/register`
  - `GET /doctors`
  - `GET /appointments` or `GET /appointments/my`
  - `GET /medical_records` or `GET /medical_records/my`
  - `GET /patients/me` (fallback: `GET /auth/me`)
  - `PUT /patients/me`

## Getting Started

1. Clone or open this container folder:
   ```
   healthcare-connect-5348-5359/healthcare_flutter_frontend
   ```

2. Create your `.env` file by copying the example:
   ```
   cp .env.example .env
   ```

3. Edit `.env` and set `BASE_URL` to your backend URL (default is `http://localhost:3001`):
   ```
   BASE_URL=http://localhost:3001
   ```

4. Install dependencies:
   ```
   flutter pub get
   ```

5. Run the app:
   ```
   flutter run
   ```

## Project Structure

```
lib/
  app_theme.dart                  # Minimalist Pure White theme
  main.dart                       # App entrypoint
  core/
    config/env.dart               # Environment loader (dotenv)
    network/api_client.dart       # Dio client with JWT injection
    router/app_router.dart        # GoRouter with auth guard and shell
  features/
    auth/
      data/auth_repository.dart   # Login/Register/Logout & token handling
      providers/auth_providers.dart
      screens/login_screen.dart
      screens/register_screen.dart
    dashboard/
      screens/dashboard_screen.dart
    doctors/
      data/doctors_repository.dart
      providers/doctors_providers.dart
      screens/doctors_list_screen.dart
    appointments/
      data/appointments_repository.dart
      screens/appointments_screen.dart
    records/
      data/records_repository.dart
      screens/records_screen.dart
    profile/
      data/profile_repository.dart
      screens/profile_screen.dart
  widgets/common_widgets.dart     # Shared minimalist widgets
```

## Environment Variables

- `BASE_URL`: The base URL of your FastAPI backend.
  - The app tries to load `.env` first and falls back to `.env.example` if not found.
  - We only include `.env.example` in `pubspec.yaml` assets so builds never fail if `.env` is missing.

## Notes

- The API client automatically injects the `Authorization: Bearer <token>` header if a JWT is stored.
- On 401 responses, the token is cleared so the router will redirect back to the login screen.
- Some feature flows (e.g., booking an appointment) include placeholders that you can expand as backend endpoints are finalized.

## Scripts

- Get packages: `flutter pub get`
- Analyze: `flutter analyze`
- Test: `flutter test`

## License

Proprietary - for internal project use.
