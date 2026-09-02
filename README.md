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

## Features

- Member login against `gravity-service` (defaults to `member@tenant-a.com`)
- **Explore demo studio** — full member flows without a backend
- Home shell with 5-tab bottom navigation and notification inbox
- Profile view, edit, membership card, and notification preferences
- Class schedule with day slider, studio filter, class detail, book, and waitlist
- Upcoming bookings with cancel and check-in
- Community tab: studio announcements + group chat
- Time-locked QR check-in

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

**Physical phone or tablet** (API on your PC; replace with your machine's LAN IP):

```bash
flutter run --dart-define=API_BASE_URL=http://<your-lan-ip>:8080
```

Native Android/iOS builds do **not** use CORS. If you see a CORS error, you are almost certainly on the **web** target (`chrome` / `web-server`). Restart `gravity-service` with the `local` profile after pulling CORS updates, or run a native device/emulator instead:

```bash
flutter run -d <device-id> --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

### Dev login (with gravity-service on `local` profile)

| Organization | Email | Password | Role |
|--------------|-------|----------|------|
| `tenant-a` | `member@tenant-a.com` | `Password123!` | Member (profile editing) |

Other seeded accounts (same password): `admin@tenant-a.com`, `owner@tenant-a.com`, `coach@tenant-a.com`, `receptionist@tenant-a.com`.

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

**Figma designs:** Screen specs, tokens, and screenshots are stored in [`docs/design/figma/`](docs/design/figma/README.md) (source: [The Gravity App - Designs](https://www.figma.com/design/94kHVaHUtL5qOgMExfXBzF/The-Gravity-App---Designs)).

## CI

GitHub Actions runs `flutter analyze` and `flutter test` on push/PR.
