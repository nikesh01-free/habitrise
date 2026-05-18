Your prompt is web/backend-heavy, but **LifeGrid is an offline mobile app**. So forcing Node.js, API, database server, auth, email, and file storage is wrong for V1.

Below is the corrected **TECH_STACK.md** for your actual app.

---

# TECH_STACK.md — LifeGrid

## 1. App Overview

| Item            | Decision                                                              |
| --------------- | --------------------------------------------------------------------- |
| App Name        | LifeGrid                                                              |
| Type            | Mobile App                                                            |
| Scale           | MVP / Small                                                           |
| Platforms       | Android, iOS                                                          |
| Offline Support | Required                                                              |
| Backend         | Not used in V1                                                        |
| Auth/Login      | Not used in V1                                                        |
| Main Goal       | Offline habit, health, focus, step, water, meal, sleep, mood tracking |

---

## 2. Version Policy

All dependencies must use **exact pinned versions**.

No version ranges:

```yaml
# ❌ Do not use
flutter_riverpod: ^3.0.0

# ✅ Use exact version
flutter_riverpod: 3.0.3
```

Flutter 3.41.x and Dart 3.11.x are current stable-era references from official Flutter/Dart release docs. ([Flutter Docs][1])

---

# 3. Frontend / Mobile Stack

## 3.1 Framework

| Item       | Decision                                             |
| ---------- | ---------------------------------------------------- |
| Technology | Flutter                                              |
| Version    | 3.41.0                                               |
| Docs       | [https://docs.flutter.dev](https://docs.flutter.dev) |

### Reason

Flutter is best for one codebase targeting Android and iOS with strong UI control, animations, local storage, and sensor access.

### Alternatives Rejected

| Alternative                | Why Rejected                                                 |
| -------------------------- | ------------------------------------------------------------ |
| React Native               | More native dependency friction for sensor-heavy mobile apps |
| Kotlin Native Android only | No iOS app from same codebase                                |
| Swift iOS only             | No Android app from same codebase                            |
| Flutter Web                | This app is mobile-first, not web-first                      |

---

## 3.2 Language

| Item       | Decision                             |
| ---------- | ------------------------------------ |
| Technology | Dart                                 |
| Version    | 3.11.0                               |
| Docs       | [https://dart.dev](https://dart.dev) |

### Reason

Dart is required for Flutter and has strong async support for timers, sensors, local DB, and UI state.

### Alternatives Rejected

| Alternative | Why Rejected                    |
| ----------- | ------------------------------- |
| TypeScript  | Not used for Flutter apps       |
| JavaScript  | Not suitable for native Flutter |
| Kotlin      | Android-only for this product   |

---

## 3.3 State Management

| Item       | Decision                                     |
| ---------- | -------------------------------------------- |
| Technology | flutter_riverpod                             |
| Version    | 3.0.3                                        |
| Docs       | [https://riverpod.dev](https://riverpod.dev) |

### Reason

Riverpod separates UI from app logic and supports scalable state for dashboard, timers, habit state, water logs, step state, and analytics. Pub.dev describes Riverpod as a reactive caching and data-binding framework that separates logic from UI and improves testability. ([Dart packages][2])

### Alternatives Rejected

| Alternative | Why Rejected                                                                              |
| ----------- | ----------------------------------------------------------------------------------------- |
| setState    | Fine for small widgets but becomes messy across dashboard, timer, calendar, and analytics |
| Provider    | Simpler, but Riverpod is cleaner for testability                                          |
| Bloc        | Good but too verbose for MVP                                                              |

---

## 3.4 Local Database

| Item       | Decision                                                       |
| ---------- | -------------------------------------------------------------- |
| Technology | Hive                                                           |
| Version    | 2.2.3                                                          |
| Docs       | [https://pub.dev/packages/hive](https://pub.dev/packages/hive) |

### Reason

Hive is fast local key-value storage and suitable for offline habit records, water logs, meals, mood logs, sleep records, rewards, and settings. Hive is described as a lightweight local database with AES-256 encryption support. ([Dart packages][3])

### Alternatives Rejected

| Alternative            | Why Rejected                                   |
| ---------------------- | ---------------------------------------------- |
| SQLite                 | More boilerplate for MVP                       |
| Isar                   | Powerful, but heavier than needed for V1       |
| SharedPreferences only | Not suitable for structured historical records |

---

## 3.5 Simple Settings Storage

| Item       | Decision                                                                                   |
| ---------- | ------------------------------------------------------------------------------------------ |
| Technology | shared_preferences                                                                         |
| Version    | 2.5.3                                                                                      |
| Docs       | [https://pub.dev/packages/shared_preferences](https://pub.dev/packages/shared_preferences) |

### Reason

Use only for small settings:

- onboarding completed
- selected theme
- notification toggles
- default water goal
- default step goal

SharedPreferences is designed for simple key-value storage, but should not be used for critical structured data. ([Dart packages][4])

### Alternatives Rejected

| Alternative         | Why Rejected                                            |
| ------------------- | ------------------------------------------------------- |
| Hive for everything | Possible, but settings are simpler in SharedPreferences |
| Secure Storage      | Not needed because no login/token in V1                 |

---

## 3.6 Local Notifications

| Item       | Decision                                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------------------------ |
| Technology | flutter_local_notifications                                                                                  |
| Version    | 19.5.0                                                                                                       |
| Docs       | [https://pub.dev/packages/flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications) |

### Reason

Needed for offline reminders:

- water reminder
- meal reminder
- study reminder
- sleep reminder
- workout reminder

The package is built for cross-platform local notification scheduling and display. ([Dart packages][5])

### Alternatives Rejected

| Alternative                          | Why Rejected                          |
| ------------------------------------ | ------------------------------------- |
| Firebase Cloud Messaging             | Requires backend/internet; not needed |
| Native Android/iOS notification code | More complex than needed              |

---

## 3.7 Step Counter

| Item       | Decision                                                                 |
| ---------- | ------------------------------------------------------------------------ |
| Technology | pedometer                                                                |
| Version    | 4.1.1                                                                    |
| Docs       | [https://pub.dev/packages/pedometer](https://pub.dev/packages/pedometer) |

### Reason

Needed to track daily steps using device sensors. The package streams step count and pedestrian status from Android/iOS pedometer APIs. ([Dart packages][6])

### Alternatives Rejected

| Alternative            | Why Rejected                                            |
| ---------------------- | ------------------------------------------------------- |
| Google Fit             | Requires account/internet integration                   |
| Apple Health           | Good later, but adds permission and platform complexity |
| Manual step input only | Weak user experience                                    |

---

## 3.8 Permission Handling

| Item       | Decision                                                                                   |
| ---------- | ------------------------------------------------------------------------------------------ |
| Technology | permission_handler                                                                         |
| Version    | 12.0.1                                                                                     |
| Docs       | [https://pub.dev/packages/permission_handler](https://pub.dev/packages/permission_handler) |

### Reason

Needed for:

- activity recognition permission
- notification permission
- app settings redirect

The package provides APIs to request and check permission status across Android and iOS. ([Dart packages][7])

### Alternatives Rejected

| Alternative                   | Why Rejected                                 |
| ----------------------------- | -------------------------------------------- |
| Manual native permission code | More platform-specific work                  |
| No permission handling        | Step counter and reminders may fail silently |

---

## 3.9 Calendar UI

| Item       | Decision                                                                           |
| ---------- | ---------------------------------------------------------------------------------- |
| Technology | table_calendar                                                                     |
| Version    | 3.2.0                                                                              |
| Docs       | [https://pub.dev/packages/table_calendar](https://pub.dev/packages/table_calendar) |

### Reason

Needed for monthly habit, mood, step, water, sleep, and meal history. It supports customizable Flutter calendars with month/week formats and event indicators. ([Dart packages][8])

### Alternatives Rejected

| Alternative                  | Why Rejected                            |
| ---------------------------- | --------------------------------------- |
| Custom calendar from scratch | Too much time for MVP                   |
| syncfusion_flutter_calendar  | Powerful but heavier for this simple V1 |

---

## 3.10 Charts / Analytics

| Item       | Decision                                                               |
| ---------- | ---------------------------------------------------------------------- |
| Technology | fl_chart                                                               |
| Version    | 1.1.1                                                                  |
| Docs       | [https://pub.dev/packages/fl_chart](https://pub.dev/packages/fl_chart) |

### Reason

Needed for:

- habit completion graph
- step trend
- water trend
- sleep trend
- focus hours chart

FL Chart supports line, bar, pie, scatter, and radar charts. ([Dart packages][9])

### Alternatives Rejected

| Alternative               | Why Rejected                           |
| ------------------------- | -------------------------------------- |
| syncfusion_flutter_charts | Bigger dependency                      |
| Custom charts             | Slower development                     |
| charts_flutter            | Less preferred for modern Flutter apps |

---

## 3.11 Animations

| Item       | Decision                                                           |
| ---------- | ------------------------------------------------------------------ |
| Technology | lottie                                                             |
| Version    | 3.3.2                                                              |
| Docs       | [https://pub.dev/packages/lottie](https://pub.dev/packages/lottie) |

### Reason

Needed for:

- streak animation
- reward unlock animation
- habit completion feedback
- empty states

Lottie renders After Effects JSON animations natively in Flutter. ([Dart packages][10])

### Alternatives Rejected

| Alternative           | Why Rejected                            |
| --------------------- | --------------------------------------- |
| Rive                  | More powerful, but extra learning curve |
| GIF animations        | Poor scaling and larger asset sizes     |
| Custom animation only | Slower for MVP                          |

---

## 3.12 Forms

| Item       | Decision                                                                                                 |
| ---------- | -------------------------------------------------------------------------------------------------------- |
| Technology | Flutter Form + TextFormField                                                                             |
| Version    | Built into Flutter 3.41.0                                                                                |
| Docs       | [https://docs.flutter.dev/cookbook/forms/validation](https://docs.flutter.dev/cookbook/forms/validation) |

### Reason

Enough for:

- habit creation
- meal creation
- water goal setting
- sleep time input
- focus duration input

### Alternatives Rejected

| Alternative    | Why Rejected                            |
| -------------- | --------------------------------------- |
| reactive_forms | Extra dependency not needed             |
| form_builder   | Useful but unnecessary for simple forms |

---

## 3.13 HTTP Client

| Item       | Decision       |
| ---------- | -------------- |
| Technology | Not used in V1 |
| Version    | N/A            |
| Docs       | N/A            |

### Reason

LifeGrid V1 is fully offline. HTTP client is unnecessary.

### Alternatives Rejected

| Alternative | Why Rejected |
| ----------- | ------------ |
| dio         | No API in V1 |
| http        | No API in V1 |

---

# 4. Backend Stack

## Backend Decision

| Backend Area      | V1 Decision |
| ----------------- | ----------- |
| Node.js           | Not used    |
| Backend Framework | Not used    |
| Server Database   | Not used    |
| ORM               | Not used    |
| Caching           | Not used    |
| Auth Libraries    | Not used    |
| File Storage      | Not used    |
| Email             | Not used    |

### Reason

Adding backend to an offline app would increase:

- development time
- cost
- bugs
- authentication complexity
- deployment complexity

For V1, all data stays on-device.

---

# 5. Environment Variables

Because V1 has no backend/API, environment variables should be minimal.

```env
APP_NAME=LifeGrid
APP_ENV=development
APP_VERSION=1.0.0
ENABLE_DEBUG_LOGS=true
ENABLE_SEED_DATA=true
LOCAL_DB_ENCRYPTION_ENABLED=false
LOCAL_BACKUP_ENABLED=true
DEFAULT_WATER_GOAL_ML=2500
DEFAULT_STEP_GOAL=8000
DEFAULT_FOCUS_MINUTES=25
MAX_WATER_LOG_ML_PER_DAY=15000
MAX_HABITS_PER_USER=50
```

## Do Not Add In V1

```env
SUPABASE_URL=
FIREBASE_API_KEY=
JWT_SECRET=
STRIPE_SECRET_KEY=
SMTP_PASSWORD=
```

These are not needed because there is no cloud backend, auth, payment, or email.

---

# 6. pubspec.yaml Dependency Lock Block

```yaml
environment:
  sdk: "3.11.0"

dependencies:
  flutter:
    sdk: flutter

  flutter_riverpod: 3.0.3
  hive: 2.2.3
  hive_flutter: 1.1.0
  shared_preferences: 2.5.3
  flutter_local_notifications: 19.5.0
  pedometer: 4.1.1
  permission_handler: 12.0.1
  table_calendar: 3.2.0
  fl_chart: 1.1.1
  lottie: 3.3.2
  intl: 0.20.2
  path_provider: 2.1.5
  uuid: 4.5.1

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: 6.0.0
  build_runner: 2.5.4
  hive_generator: 2.0.1
```

---

# 7. Backend Dependency Lock Block

```json
{
  "backend": "not-used",
  "reason": "LifeGrid V1 is offline-first and does not require Node.js, API, server database, ORM, auth, email, caching, or file storage."
}
```

---

# 8. package.json Scripts

This app does **not** need `package.json`.

Use Flutter commands instead:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

Optional `Makefile`:

```makefile
get:
	flutter pub get

analyze:
	flutter analyze

test:
	flutter test

run:
	flutter run

apk:
	flutter build apk --release

aab:
	flutter build appbundle --release

ios:
	flutter build ios --release
```

---

# 9. Security Configuration

## 9.1 Authentication

```yaml
auth:
  enabled: false
  reason: "No login in V1"
```

## 9.2 Password Hashing

```yaml
bcrypt:
  enabled: false
  rounds: 0
  reason: "No password storage in V1"
```

## 9.3 Token Expiry

```yaml
tokens:
  access_token_expiry: "not-applicable"
  refresh_token_expiry: "not-applicable"
  reason: "No backend auth in V1"
```

## 9.4 CORS

```yaml
cors:
  enabled: false
  reason: "No web API in V1"
```

## 9.5 Rate Limits

```yaml
rate_limits:
  enabled: false
  reason: "No server endpoints in V1"
```

## 9.6 Local Data Protection

```yaml
local_data:
  storage: "Hive"
  encryption_v1: false
  encryption_v2_planned: true
  backup_export: "local-device-only"
  sensitive_data_types:
    - habit history
    - water logs
    - sleep logs
    - mood logs
    - meal logs
    - focus sessions
```

---

# 10. Platform Requirements

## Android

```yaml
min_sdk: 26
target_sdk: 35
compile_sdk: 35
permissions:
  - android.permission.ACTIVITY_RECOGNITION
  - android.permission.POST_NOTIFICATIONS
```

## iOS

```yaml
minimum_ios_version: "13.0"
permissions:
  - Motion & Fitness
  - Notifications
```

---

# 11. Git Branching Strategy

```text
main
│
├── develop
│
├── feature/habit-tracking
├── feature/water-tracker
├── feature/step-counter
├── feature/focus-timer
├── feature/calendar
├── feature/analytics
│
├── fix/step-permission-error
├── fix/timer-background-state
│
└── release/v1.0.0
```

## Rules

| Branch     | Rule                      |
| ---------- | ------------------------- |
| main       | Only stable release code  |
| develop    | Active integration branch |
| feature/\* | One feature per branch    |
| fix/\*     | Bug fix branch            |
| release/\* | Release testing branch    |

---

# 12. CI/CD Setup

## GitHub Actions

```yaml
name: Flutter CI

on:
  push:
    branches:
      - main
      - develop
  pull_request:
    branches:
      - main
      - develop

jobs:
  flutter-check:
    runs-on: macos-15

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.41.0"
          channel: "stable"

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze
        run: flutter analyze

      - name: Test
        run: flutter test

      - name: Build Android APK
        run: flutter build apk --release
```

---

# 13. Version Upgrade Policy

## Flutter/Dart

| Rule                      | Policy                                 |
| ------------------------- | -------------------------------------- |
| Patch updates             | Allowed after local build + tests pass |
| Minor updates             | Review changelog first                 |
| Major updates             | Upgrade only after MVP release         |
| Emergency security update | Apply immediately after backup branch  |

---

## Package Updates

Before updating any package:

```bash
flutter pub outdated
flutter pub upgrade --major-versions --dry-run
flutter analyze
flutter test
```

Update only one critical package at a time.

---

# 14. Final Decision Summary

| Area          | Final Choice                       |
| ------------- | ---------------------------------- |
| App Framework | Flutter 3.41.0                     |
| Language      | Dart 3.11.0                        |
| State         | flutter_riverpod 3.0.3             |
| Local DB      | Hive 2.2.3                         |
| Settings      | shared_preferences 2.5.3           |
| Notifications | flutter_local_notifications 19.5.0 |
| Step Counter  | pedometer 4.1.1                    |
| Calendar      | table_calendar 3.2.0               |
| Charts        | fl_chart 1.1.1                     |
| Backend       | Not used                           |
| Auth          | Not used                           |
| API           | Not used                           |
| Cloud Storage | Not used                           |

---

# 15. What Not To Add

Do not add these in V1:

- Firebase
- Supabase
- Node.js backend
- Express/NestJS API
- PostgreSQL/MySQL
- JWT auth
- Email service
- Cloudinary
- Stripe/Razorpay
- Social login
- Admin panel

They do not match the offline-first product requirement.

[1]: https://docs.flutter.dev/release/release-notes?utm_source=chatgpt.com "Flutter release notes"
[2]: https://pub.dev/packages/flutter_riverpod "flutter_riverpod | Flutter package"
[3]: https://pub.dev/packages/hive/versions?utm_source=chatgpt.com "hive package - All Versions"
[4]: https://pub.dev/packages/shared_preferences "shared_preferences | Flutter package"
[5]: https://pub.dev/packages/flutter_local_notifications?utm_source=chatgpt.com "flutter_local_notifications | Flutter package"
[6]: https://pub.dev/packages/pedometer?utm_source=chatgpt.com "pedometer | Flutter package"
[7]: https://pub.dev/packages/permission_handler?utm_source=chatgpt.com "permission_handler | Flutter package"
[8]: https://pub.dev/packages/table_calendar "table_calendar | Flutter package"
[9]: https://pub.dev/packages/fl_chart "fl_chart | Flutter package"
[10]: https://pub.dev/packages/lottie?utm_source=chatgpt.com "lottie | Flutter package"
