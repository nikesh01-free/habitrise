# IMPLEMENTATION_PLAN.md — LifeGrid V1

## 1. Overview

| Item         | Value                                                                |
| ------------ | -------------------------------------------------------------------- |
| Project      | LifeGrid                                                             |
| App Type     | Flutter Mobile App                                                   |
| MVP Timeline | 8 weeks                                                              |
| Build Order  | Frontend first, then Supabase backend                                |
| Backend Plan | Supabase Free Plan                                                   |
| Google Maps  | Not used                                                             |
| V1 Scope     | Habits, water, steps, meals, focus, mood, sleep, calendar, analytics |


---

# Build Philosophy

1. Build complete UI first with mock/local data.
2. Connect Hive for offline local persistence.
3. Add Supabase Auth and database after frontend flows are stable.
4. Keep V1 small enough to finish.
5. Do not add Google Maps, AI food detection, social feed, chat, or admin panel.

---

# Milestones

| Milestone                | Target | Deliverables                                          |
| ------------------------ | -----: | ----------------------------------------------------- |
| M1 — Project Setup       | Week 1 | Flutter app, folders, dependencies, env config        |
| M2 — Design System       | Week 2 | Tokens, buttons, inputs, cards, loading, empty states |
| M3 — Frontend Screens    | Week 3 | Onboarding, dashboard, tracker screens                |
| M4 — Local Feature Logic | Week 4 | Hive local data, habit/water/focus/mood logic         |
| M5 — Supabase Setup      | Week 5 | Auth, database schema, RLS policies                   |
| M6 — Backend Integration | Week 6 | Supabase CRUD connected                               |
| M7 — Testing             | Week 7 | Unit/widget/integration testing                       |
| M8 — Release Build       | Week 8 | APK/AAB, smoke test, MVP checklist                    |

---

# Phase 1: Project Setup

## Step 1.1 — Initialize Flutter Project

**Duration:** 0.5 day
**Goal:** Create clean Flutter project.

**Reference:** TECH_STACK.md section 3

```bash
cd ~/Desktop
flutter create lifegrid
cd lifegrid
code .
flutter pub get
flutter run
```

## Success Criteria

* [ ] App runs on Android emulator
* [ ] App runs on iOS simulator
* [ ] No Flutter analyzer errors
* [ ] Project opens in VS Code
* [ ] Git initialized

```bash
git init
git add .
git commit -m "Initial Flutter project setup"
```

---

## Step 1.2 — Add Dependencies

**Duration:** 0.5 day
**Goal:** Add exact V1 dependencies.

```bash
flutter pub add flutter_riverpod:3.0.3
flutter pub add hive:2.2.3
flutter pub add hive_flutter:1.1.0
flutter pub add shared_preferences:2.5.3
flutter pub add flutter_local_notifications:19.5.0
flutter pub add pedometer:4.1.1
flutter pub add permission_handler:12.0.1
flutter pub add table_calendar:3.2.0
flutter pub add fl_chart:1.1.1
flutter pub add lottie:3.3.2
flutter pub add intl:0.20.2
flutter pub add path_provider:2.1.5
flutter pub add uuid:4.5.1
flutter pub add supabase_flutter:2.12.4

flutter pub add dev:build_runner:2.5.4
flutter pub add dev:hive_generator:2.0.1
flutter pub add dev:flutter_lints:6.0.0
```

## Success Criteria

* [ ] `flutter pub get` passes
* [ ] `flutter analyze` passes
* [ ] No dependency conflict
* [ ] `pubspec.lock` committed

```bash
flutter pub get
flutter analyze
git add pubspec.yaml pubspec.lock
git commit -m "Add V1 dependencies"
```

---

## Step 1.3 — Folder Structure

**Duration:** 0.5 day
**Goal:** Create maintainable app structure.

```bash
mkdir -p lib/core/theme
mkdir -p lib/core/constants
mkdir -p lib/core/errors
mkdir -p lib/core/storage
mkdir -p lib/core/widgets
mkdir -p lib/features/onboarding/presentation
mkdir -p lib/features/dashboard/presentation
mkdir -p lib/features/habits/data
mkdir -p lib/features/habits/domain
mkdir -p lib/features/habits/presentation
mkdir -p lib/features/water/data
mkdir -p lib/features/water/presentation
mkdir -p lib/features/steps/data
mkdir -p lib/features/steps/presentation
mkdir -p lib/features/focus/data
mkdir -p lib/features/focus/presentation
mkdir -p lib/features/meals/data
mkdir -p lib/features/meals/presentation
mkdir -p lib/features/mood/data
mkdir -p lib/features/mood/presentation
mkdir -p lib/features/sleep/data
mkdir -p lib/features/sleep/presentation
mkdir -p lib/features/calendar/presentation
mkdir -p lib/features/analytics/presentation
mkdir -p lib/features/settings/presentation
mkdir -p lib/features/auth/data
mkdir -p lib/features/auth/presentation
```

## Success Criteria

* [ ] Feature-first structure exists
* [ ] No business logic inside UI files
* [ ] Shared widgets placed in `core/widgets`

---

## Step 1.4 — Environment Setup

**Duration:** 0.5 day
**Goal:** Add V1 environment config.

**Reference:** TECH_STACK.md section 5

Create:

```bash
touch .env.example
touch .env
```

`.env.example`

```env
APP_NAME=LifeGrid
APP_ENV=development
APP_VERSION=1.0.0

ENABLE_DEBUG_LOGS=true
ENABLE_SEED_DATA=true

SUPABASE_URL=
SUPABASE_ANON_KEY=

DEFAULT_WATER_GOAL_ML=2500
DEFAULT_STEP_GOAL=8000
DEFAULT_FOCUS_MINUTES=25

MAX_WATER_LOG_ML_PER_DAY=15000
MAX_HABITS_PER_USER=50

GOOGLE_MAPS_API_KEY=NOT_USED
```

## Success Criteria

* [ ] `.env` is ignored by Git
* [ ] `.env.example` is committed
* [ ] No secret key committed
* [ ] Google Maps marked as not used

`.gitignore`

```gitignore
.env
```

---

# Phase 2: Design System

## Step 2.1 — Add Design Tokens

**Duration:** 1 day
**Goal:** Implement colors, text styles, spacing, radius, shadows.

**Reference:** FRONTEND_GUIDELINES.md section 2

Create:

```bash
touch lib/core/theme/app_colors.dart
touch lib/core/theme/app_text_styles.dart
touch lib/core/theme/app_spacing.dart
touch lib/core/theme/app_radius.dart
touch lib/core/theme/app_shadows.dart
touch lib/core/theme/app_theme.dart
```

## Success Criteria

* [ ] Primary color scale added
* [ ] Neutral color scale added
* [ ] Semantic colors added
* [ ] Typography added
* [ ] Light theme added
* [ ] Dark theme prepared but optional for V1

---

## Step 2.2 — Core Components

**Duration:** 2 days
**Goal:** Create reusable Flutter components.

**Reference:** FRONTEND_GUIDELINES.md section 3

Implementation order:

1. `AppButton`
2. `AppInput`
3. `AppCard`
4. `AppModal`
5. `AppToast`
6. `AppLoadingState`
7. `AppEmptyState`

```bash
touch lib/core/widgets/app_button.dart
touch lib/core/widgets/app_input.dart
touch lib/core/widgets/app_card.dart
touch lib/core/widgets/app_modal.dart
touch lib/core/widgets/app_toast.dart
touch lib/core/widgets/app_loading_state.dart
touch lib/core/widgets/app_empty_state.dart
```

## Testing

```bash
mkdir -p test/core/widgets
touch test/core/widgets/app_button_test.dart
touch test/core/widgets/app_input_test.dart
```

## Success Criteria

* [ ] Components match design tokens
* [ ] Button loading state works
* [ ] Input error state works
* [ ] Empty state reusable
* [ ] Widget tests pass

```bash
flutter test
```

---

# Phase 3: Frontend Screens First

## Step 3.1 — Onboarding UI

**Duration:** 2 days
**Goal:** Build onboarding without backend.

**Reference:** APP_FLOW.md Flow 1

Screens:

```bash
touch lib/features/onboarding/presentation/splash_screen.dart
touch lib/features/onboarding/presentation/welcome_screen.dart
touch lib/features/onboarding/presentation/goal_selection_screen.dart
touch lib/features/onboarding/presentation/starter_habits_screen.dart
touch lib/features/onboarding/presentation/permissions_screen.dart
```

## Tasks

1. Create splash screen.
2. Create welcome screen.
3. Create goal selection cards.
4. Create starter habit UI.
5. Create permissions explanation UI.
6. Store onboarding completion in SharedPreferences.

## Success Criteria

* [ ] First launch opens onboarding
* [ ] Returning user opens dashboard
* [ ] User must select at least 1 goal
* [ ] Error shown: `Please select at least one goal.`
* [ ] No Supabase required yet

---

## Step 3.2 — Main Navigation

**Duration:** 1 day
**Goal:** Add bottom navigation.

Screens:

* Dashboard
* Calendar
* Focus
* Analytics
* Settings

## Success Criteria

* [ ] Bottom nav works
* [ ] Navigation state preserved
* [ ] No blank screens
* [ ] Back button behaves correctly

---

## Step 3.3 — Dashboard UI

**Duration:** 2 days
**Goal:** Create main control center.

**Reference:** PRD.md P0 features

Dashboard cards:

* Today progress
* Habits
* Water
* Steps
* Focus
* Mood
* Meals
* Sleep

## Success Criteria

* [ ] Dashboard loads under 1 second
* [ ] Empty habit state displayed
* [ ] Water progress card visible
* [ ] Step goal card visible
* [ ] Focus card visible
* [ ] No Google Maps component exists

---

# Phase 4: Local Data + Core Features

## Step 4.1 — Local Database Setup

**Duration:** 1 day
**Goal:** Configure Hive boxes.

**Reference:** BACKEND_STRUCTURE.md section 3

Create Hive boxes:

```text
app_profile
habits
habit_logs
water_logs
step_logs
meal_logs
focus_sessions
sleep_logs
mood_logs
rewards
app_settings
```

## Tasks

1. Initialize Hive in `main.dart`.
2. Create storage service.
3. Open boxes before app start.
4. Add local schema version.

## Success Criteria

* [ ] Hive initializes on app launch
* [ ] Boxes open successfully
* [ ] App does not crash after restart
* [ ] Local data persists

---

## Step 4.2 — Habit Tracking System

**Duration:** 3 days
**Goal:** Build P0 habit system.

**Reference:** PRD.md Feature 1

## Frontend Work

1. Habit list screen
2. Add habit form
3. Edit habit form
4. Habit completion checkbox
5. Streak UI

## Local Data Work

1. `HabitModel`
2. `HabitLogModel`
3. `HabitRepository`
4. `HabitController`

## Validation

| Field     | Rule                               |
| --------- | ---------------------------------- |
| title     | 2–40 characters                    |
| frequency | daily or weekly                    |
| type      | checkbox, counter, timer, quantity |

## Success Criteria

* [ ] User can create habit
* [ ] User can edit habit
* [ ] User can archive habit
* [ ] User can complete habit once per day
* [ ] Duplicate completion blocked
* [ ] Error shown: `Habit name must be 2–40 characters.`

---

## Step 4.3 — Water Tracking

**Duration:** 2 days
**Goal:** Build manual hydration tracker.

**Reference:** PRD.md Feature 3

## Frontend Work

1. Water card
2. Water detail screen
3. Quick add buttons: `+250ml`, `+500ml`, `+1000ml`
4. Daily progress ring

## Local Data Work

1. `WaterLogModel`
2. `WaterRepository`
3. `WaterController`

## Success Criteria

* [ ] User can add water
* [ ] Daily total updates instantly
* [ ] Daily limit blocked after 15000ml
* [ ] Error shown: `Invalid water amount.`
* [ ] Data resets by date, not app restart

---

## Step 4.4 — Step Counter

**Duration:** 3 days
**Goal:** Build device step counter.

**Reference:** PRD.md Feature 2

## Frontend Work

1. Step card
2. Permission denied state
3. Sensor unavailable state
4. Daily goal progress

## Local Data Work

1. `StepLogModel`
2. `StepRepository`
3. `StepCounterService`

## Platform Permissions

Android:

```xml
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION"/>
```

iOS:

```xml
<key>NSMotionUsageDescription</key>
<string>LifeGrid uses motion data to count your daily steps.</string>
```

## Success Criteria

* [ ] Permission request works
* [ ] Steps display on dashboard
* [ ] Sensor unavailable message works
* [ ] Error shown: `Step tracking unavailable on this device.`
* [ ] Step history saved daily

---

## Step 4.5 — Focus Timer

**Duration:** 3 days
**Goal:** Build study/productivity timer.

**Reference:** PRD.md Feature 4

## Frontend Work

1. Focus screen
2. Timer presets
3. Start/pause/reset buttons
4. Completion screen

## Local Data Work

1. `FocusSessionModel`
2. `FocusRepository`
3. `FocusTimerController`

## Success Criteria

* [ ] User can start timer
* [ ] User can pause timer
* [ ] Only one timer runs at once
* [ ] Completed session saved
* [ ] Error shown: `A focus timer is already running.`

---

## Step 4.6 — Mood Tracking

**Duration:** 1 day
**Goal:** Build daily mood logger.

**Reference:** PRD.md Feature 5

## Success Criteria

* [ ] User can select mood
* [ ] One mood entry per day
* [ ] Same-day mood can be edited
* [ ] Calendar indicator updates
* [ ] Error shown: `You have already logged today’s mood.`

---

## Step 4.7 — Calendar View

**Duration:** 2 days
**Goal:** Show daily history.

**Reference:** PRD.md Feature 6

## Success Criteria

* [ ] Calendar displays month view
* [ ] Date tap opens day details
* [ ] Habit, water, mood, steps shown per day
* [ ] Empty state works
* [ ] Month switching under 500ms

---

# Phase 5: Supabase Backend Setup

## Step 5.1 — Create Supabase Project

**Duration:** 0.5 day
**Goal:** Create free Supabase project.

**Reference:** TECH_STACK.md backend decision update

Use Supabase Free Plan only.

## Tasks

1. Create Supabase project.
2. Copy project URL.
3. Copy anon public key.
4. Add values to `.env`.

```env
SUPABASE_URL=your_project_url
SUPABASE_ANON_KEY=your_anon_key
```

## Success Criteria

* [ ] Supabase project created
* [ ] URL added locally
* [ ] Anon key added locally
* [ ] No service role key used in Flutter app

---

## Step 5.2 — Supabase Auth

**Duration:** 1.5 days
**Goal:** Add email/password auth.

Supabase Auth supports user authentication and authorization through client SDKs. ([Supabase][2])

## Frontend Screens

* Login
* Register
* Forgot Password
* Profile Settings
* Logout

## Success Criteria

* [ ] User can register
* [ ] User can login
* [ ] User can logout
* [ ] Invalid login shows error
* [ ] Logged-in session persists

---

## Step 5.3 — Supabase Database Schema

**Duration:** 2 days
**Goal:** Create cloud tables matching local entities.

Supabase projects include a Postgres database. ([Supabase][3])

## Tables

* profiles
* habits
* habit_logs
* water_logs
* step_logs
* meal_logs
* focus_sessions
* sleep_logs
* mood_logs
* rewards

## SQL Migration

```sql
create table profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name varchar(50),
  user_type varchar(30) not null default 'student',
  selected_goals text[] not null default '{}',
  default_step_goal integer not null default 8000,
  default_water_goal_ml integer not null default 2500,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title varchar(40) not null,
  category varchar(30) not null,
  type varchar(20) not null,
  frequency varchar(20) not null,
  target_value numeric(10,2),
  unit varchar(20),
  icon varchar(50),
  color_hex varchar(7) not null default '#3B82F6',
  reminder_enabled boolean not null default false,
  reminder_time varchar(5),
  is_archived boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table habit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  habit_id uuid not null references habits(id) on delete cascade,
  log_date date not null,
  status varchar(20) not null,
  completed_value numeric(10,2),
  note varchar(255),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(habit_id, log_date)
);

create table water_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  amount_ml integer not null check (amount_ml > 0 and amount_ml <= 15000),
  entry_time timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table step_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  steps integer not null check (steps >= 0 and steps <= 100000),
  goal_steps integer not null default 8000,
  distance_km numeric(10,2),
  calories numeric(10,2),
  source varchar(20) not null default 'pedometer',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, log_date)
);

create table meal_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  meal_name varchar(40) not null,
  meal_type varchar(20) not null,
  status varchar(20) not null,
  planned_time varchar(5),
  completed_time timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, log_date, meal_name)
);

create table focus_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category varchar(30) not null,
  planned_minutes integer not null check (planned_minutes >= 5 and planned_minutes <= 180),
  completed_minutes integer not null check (completed_minutes >= 0 and completed_minutes <= 180),
  status varchar(20) not null,
  started_at timestamptz not null,
  ended_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table mood_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  log_date date not null,
  mood varchar(20) not null,
  note varchar(255),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, log_date)
);

create table sleep_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  sleep_date date not null,
  sleep_time timestamptz not null,
  wake_time timestamptz not null,
  total_minutes integer not null check (total_minutes >= 0),
  quality varchar(20),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(user_id, sleep_date)
);
```

## Indexes

```sql
create index idx_habits_user_id on habits(user_id);
create index idx_habit_logs_user_date on habit_logs(user_id, log_date);
create index idx_water_logs_user_date on water_logs(user_id, log_date);
create index idx_step_logs_user_date on step_logs(user_id, log_date);
create index idx_meal_logs_user_date on meal_logs(user_id, log_date);
create index idx_focus_sessions_user_started on focus_sessions(user_id, started_at);
create index idx_mood_logs_user_date on mood_logs(user_id, log_date);
create index idx_sleep_logs_user_date on sleep_logs(user_id, sleep_date);
```

## Success Criteria

* [ ] All tables created
* [ ] All constraints work
* [ ] All indexes created
* [ ] No Google Maps table exists
* [ ] No image/photo table exists

---

## Step 5.4 — Row Level Security

**Duration:** 1 day
**Goal:** Ensure users only access their own data.

```sql
alter table profiles enable row level security;
alter table habits enable row level security;
alter table habit_logs enable row level security;
alter table water_logs enable row level security;
alter table step_logs enable row level security;
alter table meal_logs enable row level security;
alter table focus_sessions enable row level security;
alter table mood_logs enable row level security;
alter table sleep_logs enable row level security;
```

Example policy:

```sql
create policy "Users can manage own habits"
on habits
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);
```

Apply same pattern to other user-owned tables.

## Success Criteria

* [ ] User cannot read another user’s records
* [ ] User cannot insert data for another user ID
* [ ] Supabase anon key is safe for app usage
* [ ] RLS tested manually

---

# Phase 6: Supabase Integration

## Step 6.1 — Initialize Supabase in Flutter

**Duration:** 0.5 day
**Goal:** Connect Flutter app to Supabase.

The Flutter package `supabase_flutter` is the official Flutter integration for Supabase. ([Dart packages][4])

```dart
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
);
```

## Success Criteria

* [ ] Supabase initializes without crash
* [ ] Missing env values show safe error
* [ ] No service role key included

---

## Step 6.2 — Auth Integration

**Duration:** 2 days
**Goal:** Connect login/register/logout screens.

## Success Criteria

* [ ] Register creates Supabase user
* [ ] Login creates session
* [ ] Logout clears session
* [ ] Invalid credentials show clear error
* [ ] Session persists after app restart

---

## Step 6.3 — Data Sync Strategy

**Duration:** 3 days
**Goal:** Sync local data to Supabase after login.

## Rules

| Case                | Behavior                             |
| ------------------- | ------------------------------------ |
| User not logged in  | Save only locally                    |
| User logs in        | Upload local unsynced records        |
| Network unavailable | Continue local-first                 |
| Supabase error      | Queue retry                          |
| Duplicate record    | Use unique keys to prevent duplicate |

## Success Criteria

* [ ] App works offline
* [ ] Local data saves first
* [ ] Supabase sync happens after save
* [ ] Failed sync does not block user
* [ ] Duplicate habit logs prevented

---

# Phase 7: Testing

## Step 7.1 — Unit Tests

**Duration:** 2 days
**Goal:** Test business logic.

Coverage targets:

| Module             | Target |
| ------------------ | -----: |
| Habit logic        |    80% |
| Water validation   |    90% |
| Focus timer logic  |    80% |
| Mood logic         |    80% |
| Local repositories |    75% |

```bash
flutter test
```

## Success Criteria

* [ ] Habit duplicate completion test passes
* [ ] Water max limit test passes
* [ ] Focus one-active-timer test passes
* [ ] Mood one-per-day test passes

---

## Step 7.2 — Widget Tests

**Duration:** 1.5 days
**Goal:** Test UI states.

Test:

* Button loading state
* Input error state
* Empty habits state
* Dashboard cards
* Permission denied state

## Success Criteria

* [ ] Core components tested
* [ ] Main screens render without crash
* [ ] Error messages visible

---

## Step 7.3 — End-to-End Flow Tests

**Duration:** 2 days
**Reference:** APP_FLOW.md section 2

Flows:

1. Onboarding → Dashboard
2. Create habit → Complete habit
3. Add water → Dashboard update
4. Start focus timer → Complete session
5. Login → Sync data

## Success Criteria

* [ ] All P0 flows pass
* [ ] App does not crash during navigation
* [ ] Offline mode works
* [ ] Supabase failure does not break local usage

---

# Phase 8: Deployment

## Step 8.1 — Android Release Build

**Duration:** 1 day

```bash
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release
flutter build appbundle --release
```

## Success Criteria

* [ ] APK builds successfully
* [ ] AAB builds successfully
* [ ] App opens on real Android device
* [ ] No debug banner
* [ ] No Google Maps permission requested

---

## Step 8.2 — iOS Release Check

**Duration:** 1 day

```bash
cd ios
pod install
cd ..
flutter build ios --release
```

## Success Criteria

* [ ] iOS build succeeds
* [ ] Motion permission text exists
* [ ] Notification permission works
* [ ] App runs on simulator

---

# Risk Mitigation

| Risk                    | Impact             | Mitigation                                 |
| ----------------------- | ------------------ | ------------------------------------------ |
| Too many features       | MVP delay          | Build P0 only                              |
| Step counter unstable   | Poor UX            | Add permission/sensor fallback             |
| Supabase RLS mistake    | Data leak risk     | Test with 2 accounts                       |
| Sync conflicts          | Duplicate data     | Use unique constraints                     |
| UI becomes crowded      | Bad usability      | Dashboard cards only                       |
| Free plan limits        | App interruption   | Keep V1 low data usage                     |
| Timer background issues | Bad focus tracking | Save start time and calculate elapsed time |
| User denies permissions | Feature blocked    | Show manual fallback states                |

---

# Overall MVP Success Criteria

* [ ] User can complete onboarding
* [ ] User can create and complete habits
* [ ] User can track water manually
* [ ] User can view steps if permission is granted
* [ ] User can use focus timer
* [ ] User can log mood
* [ ] User can view calendar history
* [ ] User can register/login with Supabase
* [ ] User data syncs to Supabase
* [ ] App still works offline
* [ ] No Google Maps used
* [ ] No AI/photo detection used
* [ ] No social features used
* [ ] Android release build generated

---


Do not start backend before the frontend flows are stable. That is where most beginner projects become stuck.

[1]: https://supabase.com/docs?utm_source=chatgpt.com "Supabase Docs"
[2]: https://supabase.com/docs/guides/auth?utm_source=chatgpt.com "Auth | Supabase Docs"
[3]: https://supabase.com/docs/guides/database/overview?utm_source=chatgpt.com "Database | Supabase Docs"
[4]: https://pub.dev/packages/supabase_flutter?utm_source=chatgpt.com "supabase_flutter | Flutter package"
