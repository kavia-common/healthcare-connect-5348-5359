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
- A running FastAPI backend

## Quickstart

1) Configure environment
- Copy `.env.example` to `.env`:
  ```
  cp .env.example .env
  ```
- Set backend URL (match backend port 3001):
  ```
  BASE_URL=http://localhost:3001
  ```

2) Start dependencies
- Ensure MongoDB is running at `mongodb://localhost:5001` (see database README)
- Start backend on port 3001:
  ```
  uvicorn app.main:app --reload --port 3001
  ```
- Confirm API is up: open http://localhost:3001/docs

3) Install Flutter dependencies
```
flutter pub get
```

4) Run the app
```
flutter run
```

Notes:
- The app loads `.env` if present, otherwise falls back to `.env.example`.
- For Flutter web, ensure the backend CORS includes your web origin (see backend `CORS_ORIGINS`).

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
  - Example: `http://localhost:3001`
  - The app tries to load `.env` first and falls back to `.env.example` if not found.
  - Only `.env.example` is included in assets so builds never fail if `.env` is missing.

## E2E Validation Checklist

1) Register (or prepare a user)
- Backend /auth/register requires a `role` (e.g., `"patient"`). If using the current frontend, registration may need adjustment (see Troubleshooting).

2) Login
- Use valid credentials on `/auth/login`.
- Ensure a token is stored and protected routes are accessible.

3) View doctors
- Open the Doctors tab; ensure the list loads from `/doctors`.

4) Book consultation
- Backend supports `/consultations`; current UI shows a placeholder button in Doctors screen.

5) View appointments
- Current frontend tries `/appointments` endpoints; backend exposes `/consultations`.
- See Troubleshooting for endpoint alignment.

6) View records
- Open Records tab; mapping to backend fields may be needed (see Troubleshooting).

## Troubleshooting (Backend Alignment)

- Registration payload mismatch:
  - Frontend sends `{ name, email, password }` to `/auth/register`.
  - Backend requires `role` (e.g., `"patient"`) and uses `full_name` (optional).
  - Workarounds:
    - Register via a REST client with `{ "email": "...", "password": "...", "role": "patient", "full_name": "..." }`.
    - Or update `lib/features/auth/data/auth_repository.dart` to include a default role (e.g., `"patient"`) and rename `name` to `full_name`.

- Appointments vs Consultations:
  - Frontend calls `/appointments` endpoints.
  - Backend exposes `/consultations`.
  - Update `lib/features/appointments/data/appointments_repository.dart` to use `/consultations` and map fields.

- Doctors list fields:
  - Backend `DoctorPublic` includes `{ id, user_id, specialty, years_experience, bio }`.
  - Current UI expects `name` and `hospital`.
  - Update the UI to show available backend fields (e.g., use `specialty` as subtitle) or extend backend payload to include `full_name`.

- Records fields:
  - Backend returns `diagnosis`, `treatments`, `created_at`.
  - UI expects `title`, `summary`, `date`.
  - Map `title` -> `diagnosis`, `summary` -> `treatments`, `date` -> `created_at`.

- Profiles:
  - `GET /patients/me` returns patient profile fields like `user_id`, `age`, `gender`, `address`, `phone` (no `name`).
  - Update `ProfileRepository` and UI to reflect actual backend fields.

- Network errors:
  - Ensure `BASE_URL` matches backend URL and port (default in this project: `http://localhost:3001`).
  - If using Flutter web, ensure `CORS_ORIGINS` on backend includes your origin.

## Scripts

- Get packages: `flutter pub get`
- Analyze: `flutter analyze`
- Test: `flutter test`

## License

Proprietary - for internal project use.
