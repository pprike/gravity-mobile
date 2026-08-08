# gravity-mobile

Flutter member app for the [Gravity](https://github.com/pprike/gravity-docs) multi-tenant fitness platform.

## Related repositories

| Repository | Description |
|------------|-------------|
| [gravity-service](https://github.com/pprike/gravity-service) | Spring Boot REST API |
| [gravity-ui](https://github.com/pprike/gravity-ui) | Next.js admin portal |
| [gravity-docs](https://github.com/pprike/gravity-docs) | Product, architecture, API, and UX documentation |

## Stack

- Flutter 3.x
- Riverpod (state management)
- go_router (navigation)
- Dio (HTTP client)

## Features (initial scaffold)

- Member login against `gravity-service`
- Home shell with bottom navigation (dashboard placeholder)
- Profile view and edit with avatar upload (GRA-113)

## Local development

### Prerequisites

- Flutter SDK 3.12+
- [gravity-service](https://github.com/pprike/gravity-service) running locally on port 8080 (`local` profile)

### Setup

```bash
flutter pub get
```

### Run

**iOS simulator / desktop / web** (API on localhost):

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:8080
```

**Android emulator** (API on host machine):

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

### Dev login (with gravity-service on `local` profile)

| Organization | Email | Password |
|--------------|-------|----------|
| `tenant-a` | `receptionist@tenant-a.com` | `Password123!` |

Other seeded staff accounts: `admin@tenant-a.com`, `owner@tenant-a.com`, `coach@tenant-a.com` (same password). Profile editing requires a **Member** role; the local seed does not include a member account yet—use integration-test fixtures or add a member user in the API for full profile flows.

## Scripts

| Command | Description |
|---------|-------------|
| `flutter run` | Run the app on a connected device or emulator |
| `flutter analyze` | Static analysis |
| `flutter test` | Unit and widget tests |

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `API_BASE_URL` | `http://localhost:8080` | Base URL for the Gravity API (pass via `--dart-define`) |

## Documentation

UX flows, information architecture, and feature specs live in [gravity-docs](https://github.com/pprike/gravity-docs).

## CI

GitHub Actions runs `flutter analyze` and `flutter test` on push/PR.
