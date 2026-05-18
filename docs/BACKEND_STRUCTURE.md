# BACKEND_STRUCTURE.md — LifeGrid

## Important Decision

LifeGrid V1 has **no server backend**.

This app uses:

* local database
* local notifications
* device sensors
* offline-first storage
* no login
* no API
no supabase
* no cloud sync

So this document defines the **Local Data Backend Structure**, not Node.js/API backend.

---

# 1. Architecture Overview

## Architecture Pattern

```text
Flutter UI
↓
Riverpod State Providers
↓
Repository Layer
↓
Local Hive Database
↓
Device Storage
```

## Auth Strategy

```text
Auth: Not used in V1
Login: Not used
Sessions: Not used
JWT: Not used
Password: Not stored
```

Reason: LifeGrid is an offline personal tracker. Requiring login would add friction and backend cost.

---

## Data Flow

```text
User Action
↓
Validation
↓
Riverpod Controller
↓
Repository
↓
Hive Box
↓
UI Refresh
```

Example:

```text
User taps +250ml water
↓
Validate daily total <= 15000ml
↓
Save water log locally
↓
Update dashboard progress
```

---

## Caching

No external cache is needed.

Local cache is handled by:

```text
Hive local storage
SharedPreferences settings
In-memory Riverpod state
```

---

# 2. Local Database Structure

Hive does not use SQL tables, but data should still be structured like entities.

Each entity must include:

```dart
id
createdAt
updatedAt
```

Use UUID strings for IDs.

---

# 3. Local Boxes / Entity Schemas

---

# 3.1 app_profile

Stores local user profile and onboarding state.

| Field                 | Type         | Constraints             | Description                                 |
| --------------------- | ------------ | ----------------------- | ------------------------------------------- |
| id                    | String UUID  | required, unique        | Local profile ID                            |
| display_name          | String       | nullable, max 50        | User name                                   |
| user_type             | String       | required                | student, fitness, wellness, senior, working |
| selected_goals        | List<String> | required, default []    | User selected goals                         |
| onboarding_completed  | bool         | required, default false | Whether onboarding is complete              |
| default_step_goal     | int          | required, default 8000  | Daily step target                           |
| default_water_goal_ml | int          | required, default 2500  | Daily water target                          |
| created_at            | DateTime     | required                | Created timestamp                           |
| updated_at            | DateTime     | required                | Updated timestamp                           |

## Indexes

| Index   | Field                |
| ------- | -------------------- |
| primary | id                   |
| query   | onboarding_completed |
| query   | user_type            |

---

# 3.2 habits

Stores user-created habits.

| Field            | Type        | Constraints             | Description                              |
| ---------------- | ----------- | ----------------------- | ---------------------------------------- |
| id               | String UUID | required, unique        | Habit ID                                 |
| title            | String      | required, 2–40 chars    | Habit name                               |
| category         | String      | required                | health, study, fitness, wellness, custom |
| type             | String      | required                | checkbox, counter, timer, quantity       |
| frequency        | String      | required                | daily, weekly                            |
| target_value     | double      | nullable                | Target count/time/quantity               |
| unit             | String      | nullable                | ml, steps, minutes, reps                 |
| icon             | String      | nullable                | Icon key                                 |
| color_hex        | String      | required                | Habit color                              |
| reminder_enabled | bool        | required, default false | Reminder status                          |
| reminder_time    | String      | nullable                | HH:mm                                    |
| is_archived      | bool        | required, default false | Soft delete flag                         |
| created_at       | DateTime    | required                | Created timestamp                        |
| updated_at       | DateTime    | required                | Updated timestamp                        |

## Indexes

| Index   | Field       |
| ------- | ----------- |
| primary | id          |
| query   | category    |
| query   | frequency   |
| query   | is_archived |

## Relationships

```text
habits 1 → many habit_logs
```

---

# 3.3 habit_logs

Stores daily habit completion.

| Field           | Type        | Constraints          | Description                   |
| --------------- | ----------- | -------------------- | ----------------------------- |
| id              | String UUID | required, unique     | Log ID                        |
| habit_id        | String UUID | required             | References habits.id          |
| log_date        | String      | required, YYYY-MM-DD | Completion date               |
| status          | String      | required             | completed, missed, skipped    |
| completed_value | double      | nullable             | Completed count/time/quantity |
| note            | String      | nullable, max 255    | Optional note                 |
| created_at      | DateTime    | required             | Created timestamp             |
| updated_at      | DateTime    | required             | Updated timestamp             |

## Indexes

| Index   | Field               |
| ------- | ------------------- |
| primary | id                  |
| foreign | habit_id            |
| query   | log_date            |
| unique  | habit_id + log_date |

## Relationship

```text
habit_logs many → 1 habits
```

## Delete Rule

```text
If habit is deleted, delete related habit_logs.
```

---

# 3.4 water_logs

Stores daily water entries.

| Field      | Type        | Constraints                | Description       |
| ---------- | ----------- | -------------------------- | ----------------- |
| id         | String UUID | required, unique           | Water log ID      |
| log_date   | String      | required, YYYY-MM-DD       | Date              |
| amount_ml  | int         | required, min 1, max 15000 | Water amount      |
| entry_time | DateTime    | required                   | Entry timestamp   |
| created_at | DateTime    | required                   | Created timestamp |
| updated_at | DateTime    | required                   | Updated timestamp |

## Indexes

| Index   | Field      |
| ------- | ---------- |
| primary | id         |
| query   | log_date   |
| query   | entry_time |

---

# 3.5 step_logs

Stores daily step history.

| Field       | Type        | Constraints                  | Description        |
| ----------- | ----------- | ---------------------------- | ------------------ |
| id          | String UUID | required, unique             | Step log ID        |
| log_date    | String      | required, unique, YYYY-MM-DD | Date               |
| steps       | int         | required, min 0              | Total steps        |
| goal_steps  | int         | required, default 8000       | Daily step goal    |
| distance_km | double      | nullable                     | Estimated distance |
| calories    | double      | nullable                     | Estimated calories |
| source      | String      | required                     | pedometer, manual  |
| created_at  | DateTime    | required                     | Created timestamp  |
| updated_at  | DateTime    | required                     | Updated timestamp  |

## Indexes

| Index   | Field    |
| ------- | -------- |
| primary | id       |
| unique  | log_date |

---

# 3.6 meal_logs

Stores meal completion records.

| Field          | Type        | Constraints          | Description                             |
| -------------- | ----------- | -------------------- | --------------------------------------- |
| id             | String UUID | required, unique     | Meal log ID                             |
| log_date       | String      | required, YYYY-MM-DD | Date                                    |
| meal_name      | String      | required, max 40     | Breakfast, lunch, dinner, custom        |
| meal_type      | String      | required             | breakfast, lunch, dinner, snack, custom |
| status         | String      | required             | completed, skipped, delayed             |
| planned_time   | String      | nullable, HH:mm      | Planned meal time                       |
| completed_time | DateTime    | nullable             | Completion time                         |
| created_at     | DateTime    | required             | Created timestamp                       |
| updated_at     | DateTime    | required             | Updated timestamp                       |

## Indexes

| Index   | Field                |
| ------- | -------------------- |
| primary | id                   |
| query   | log_date             |
| query   | meal_type            |
| unique  | log_date + meal_name |

---

# 3.7 focus_sessions

Stores study/productivity sessions.

| Field             | Type        | Constraints              | Description                    |
| ----------------- | ----------- | ------------------------ | ------------------------------ |
| id                | String UUID | required, unique         | Focus session ID               |
| category          | String      | required                 | study, coding, reading, custom |
| planned_minutes   | int         | required, min 5, max 180 | Planned duration               |
| completed_minutes | int         | required, min 0          | Completed duration             |
| status            | String      | required                 | completed, cancelled, partial  |
| started_at        | DateTime    | required                 | Start time                     |
| ended_at          | DateTime    | nullable                 | End time                       |
| created_at        | DateTime    | required                 | Created timestamp              |
| updated_at        | DateTime    | required                 | Updated timestamp              |

## Indexes

| Index   | Field      |
| ------- | ---------- |
| primary | id         |
| query   | category   |
| query   | started_at |
| query   | status     |

---

# 3.8 sleep_logs

Stores manual sleep records.

| Field         | Type        | Constraints          | Description                 |
| ------------- | ----------- | -------------------- | --------------------------- |
| id            | String UUID | required, unique     | Sleep log ID                |
| sleep_date    | String      | required, YYYY-MM-DD | Sleep date                  |
| sleep_time    | DateTime    | required             | Sleep start                 |
| wake_time     | DateTime    | required             | Wake time                   |
| total_minutes | int         | required, min 0      | Calculated sleep duration   |
| quality       | String      | nullable             | poor, okay, good, excellent |
| created_at    | DateTime    | required             | Created timestamp           |
| updated_at    | DateTime    | required             | Updated timestamp           |

## Indexes

| Index   | Field      |
| ------- | ---------- |
| primary | id         |
| unique  | sleep_date |

---

# 3.9 mood_logs

Stores daily mood.

| Field      | Type        | Constraints                  | Description                   |
| ---------- | ----------- | ---------------------------- | ----------------------------- |
| id         | String UUID | required, unique             | Mood log ID                   |
| log_date   | String      | required, unique, YYYY-MM-DD | Date                          |
| mood       | String      | required                     | great, good, okay, bad, tired |
| note       | String      | nullable, max 255            | Optional mood note            |
| created_at | DateTime    | required                     | Created timestamp             |
| updated_at | DateTime    | required                     | Updated timestamp             |

## Indexes

| Index   | Field    |
| ------- | -------- |
| primary | id       |
| unique  | log_date |
| query   | mood     |

---

# 3.10 rewards

Stores reward definitions and unlock state.

| Field            | Type        | Constraints             | Description                 |
| ---------------- | ----------- | ----------------------- | --------------------------- |
| id               | String UUID | required, unique        | Reward ID                   |
| title            | String      | required, max 50        | Reward title                |
| description      | String      | required, max 255       | Reward description          |
| reward_type      | String      | required                | badge, theme, streak, frame |
| unlock_condition | String      | required                | Condition key               |
| unlocked_at      | DateTime    | nullable                | Unlock timestamp            |
| is_unlocked      | bool        | required, default false | Unlock status               |
| created_at       | DateTime    | required                | Created timestamp           |
| updated_at       | DateTime    | required                | Updated timestamp           |

## Indexes

| Index   | Field       |
| ------- | ----------- |
| primary | id          |
| query   | reward_type |
| query   | is_unlocked |

---

# 3.11 app_settings

Stores app preferences.

| Field                  | Type        | Constraints              | Description           |
| ---------------------- | ----------- | ------------------------ | --------------------- |
| id                     | String UUID | required, unique         | Settings ID           |
| theme_mode             | String      | required, default system | light, dark, system   |
| accent_color           | String      | required                 | Hex color             |
| notifications_enabled  | bool        | required, default true   | Notification status   |
| step_tracking_enabled  | bool        | required, default false  | Step tracking status  |
| reduced_motion_enabled | bool        | required, default false  | Accessibility setting |
| created_at             | DateTime    | required                 | Created timestamp     |
| updated_at             | DateTime    | required                 | Updated timestamp     |

---

# 4. API Endpoints

## V1 Decision

LifeGrid V1 has **no HTTP API endpoints**.

The following are intentionally not built:

```text
POST /auth/register
POST /auth/login
POST /auth/logout
POST /auth/refresh
GET /habits
POST /habits
PATCH /habits/:id
DELETE /habits/:id
```

Reason:

```text
No backend server exists in V1.
All CRUD happens locally inside the app.
```

---

# 5. Local Repository Actions

Instead of API endpoints, use repository methods.

---

## 5.1 Habit Repository

```dart
createHabit(Habit habit)
updateHabit(Habit habit)
archiveHabit(String habitId)
deleteHabit(String habitId)
getActiveHabits()
completeHabit(String habitId, DateTime date)
getHabitLogsByDate(DateTime date)
```

## Error Cases

| Error Code            | When                               |
| --------------------- | ---------------------------------- |
| habit_title_required  | Title is empty                     |
| habit_title_too_short | Title under 2 characters           |
| habit_title_too_long  | Title over 40 characters           |
| habit_not_found       | Habit ID does not exist            |
| duplicate_habit_log   | Same habit completed for same date |

---

## 5.2 Water Repository

```dart
addWaterLog(int amountMl)
removeWaterLog(String logId)
getWaterTotalByDate(DateTime date)
getWaterLogsByDate(DateTime date)
```

## Validation

| Field       | Rule                    |
| ----------- | ----------------------- |
| amount_ml   | 1–15000                 |
| daily_total | must not exceed 15000ml |

## Error Message

```text
Invalid water amount.
```

---

## 5.3 Step Repository

```dart
saveDailySteps(DateTime date, int steps)
getStepsByDate(DateTime date)
getStepHistory(DateTime start, DateTime end)
```

## Validation

| Field      | Rule       |
| ---------- | ---------- |
| steps      | 0–100000   |
| goal_steps | 500–100000 |

---

## 5.4 Focus Repository

```dart
startFocusSession(FocusSession session)
completeFocusSession(String sessionId)
cancelFocusSession(String sessionId)
getFocusSessionsByDate(DateTime date)
```

## Validation

| Field             | Rule  |
| ----------------- | ----- |
| planned_minutes   | 5–180 |
| completed_minutes | 0–180 |

---

# 6. Authentication

## V1 Auth

```json
{
  "authEnabled": false,
  "reason": "LifeGrid V1 is offline-only and does not require accounts."
}
```

## JWT Payload

Not applicable.

```json
{
  "accessToken": "not_used",
  "refreshToken": "not_used"
}
```

## Password Hashing

Not applicable.

```json
{
  "bcryptRounds": 0,
  "reason": "No passwords are stored."
}
```

## Authorization Levels

| Level             | Route Examples  |
| ----------------- | --------------- |
| Public Local User | All app screens |
| Admin             | Not used        |
| Guest             | Not used        |

---

# 7. Standard Local Error Format

Even without APIs, use a consistent app error object.

```json
{
  "success": false,
  "error": {
    "code": "habit_not_found",
    "message": "Habit could not be found.",
    "details": {
      "habitId": "uuid"
    }
  }
}
```

## Error Code Mapping

| Code                    | UI Message                                  |
| ----------------------- | ------------------------------------------- |
| habit_not_found         | Habit could not be found.                   |
| invalid_water_amount    | Invalid water amount.                       |
| step_sensor_unavailable | Step tracking unavailable on this device.   |
| permission_denied       | Permission is required to use this feature. |
| storage_write_failed    | Unable to save progress. Please try again.  |
| backup_corrupted        | Backup file is invalid or corrupted.        |
| timer_already_running   | A focus timer is already running.           |

---

# 8. Caching Strategy

## V1 Cache Layers

| Layer                    | Used For                 | TTL               |
| ------------------------ | ------------------------ | ----------------- |
| Riverpod in-memory state | Current dashboard values | Until app restart |
| Hive local DB            | Persistent records       | Permanent         |
| SharedPreferences        | Small settings           | Permanent         |

## Cache Keys

```text
dashboard_today_YYYY_MM_DD
water_total_YYYY_MM_DD
habit_logs_YYYY_MM_DD
step_total_YYYY_MM_DD
focus_sessions_YYYY_MM_DD
```

## Invalidation Rules

| Action                  | Invalidate                      |
| ----------------------- | ------------------------------- |
| Habit completed         | dashboard_today, habit_logs     |
| Water added             | dashboard_today, water_total    |
| Steps updated           | dashboard_today, step_total     |
| Focus session completed | dashboard_today, focus_sessions |
| Sleep logged            | dashboard_today                 |
| Mood logged             | dashboard_today                 |

---

# 9. Rate Limiting

No server rate limiting is required.

Use local interaction protection instead.

| Action                  | Limit                         |
| ----------------------- | ----------------------------- |
| Habit completion tap    | Debounce 500ms                |
| Water quick-add tap     | Debounce 300ms                |
| Timer start             | Only 1 active timer           |
| Backup restore          | 1 restore operation at a time |
| Notification scheduling | Max 64 active reminders       |

---

# 10. Migration Strategy

## Tool

Hive manual migration using schema version.

```dart
const int localSchemaVersion = 1;
```

## Migration Process

```text
1. Read current local schema version
2. Compare with app schema version
3. If old version found, run migration scripts
4. Backup old boxes before migration
5. Write new schema version after success
6. If migration fails, restore backup
```

## Migration Example

```dart
Future<void> runMigrations() async {
  final currentVersion = settingsBox.get('schema_version', defaultValue: 1);

  if (currentVersion < 2) {
    await migrateV1ToV2();
    await settingsBox.put('schema_version', 2);
  }
}
```

## Rollback Strategy

```text
If migration fails:
- stop migration
- restore previous local backup
- show error screen
- allow user to retry
```

## Error Message

```text
Some local data could not be upgraded. Please restore backup or retry.
```

---

# 11. What Is Explicitly Not Built

These backend features are not part of V1:

1. Server database
2. Node.js API
3. Login/register
4. JWT authentication
5. Refresh tokens
6. Admin panel
7. Cloud sync
8. Email verification
9. Password reset
10. Redis caching
11. Webhooks
12. Payment system
13. Multi-device sync

---

# 12. Future Backend Option

Only consider backend in V2 if user needs:

* cloud backup
* multi-device sync
* login
* family sharing
* admin dashboard
* premium subscription

Recommended V2 backend:

```text
Supabase
PostgreSQL
Supabase Auth
Supabase Storage
Edge Functions
```

But do **not** add this in V1.
# BACKEND_STRUCTURE.md — LifeGrid

## Important Decision

LifeGrid V1 has **no server backend**.

This app uses:

* local database
* local notifications
* device sensors
* offline-first storage
* no login
* no API
* no cloud sync

So this document defines the **Local Data Backend Structure**, not Node.js/API backend.

---

# 1. Architecture Overview

## Architecture Pattern

```text
Flutter UI
↓
Riverpod State Providers
↓
Repository Layer
↓
Local Hive Database
↓
Device Storage
```

## Auth Strategy

```text
Auth: Not used in V1
Login: Not used
Sessions: Not used
JWT: Not used
Password: Not stored
```

Reason: LifeGrid is an offline personal tracker. Requiring login would add friction and backend cost.

---

## Data Flow

```text
User Action
↓
Validation
↓
Riverpod Controller
↓
Repository
↓
Hive Box
↓
UI Refresh
```

Example:

```text
User taps +250ml water
↓
Validate daily total <= 15000ml
↓
Save water log locally
↓
Update dashboard progress
```

---

## Caching

No external cache is needed.

Local cache is handled by:

```text
Hive local storage
SharedPreferences settings
In-memory Riverpod state
```

---

# 2. Local Database Structure

Hive does not use SQL tables, but data should still be structured like entities.

Each entity must include:

```dart
id
createdAt
updatedAt
```

Use UUID strings for IDs.

---

# 3. Local Boxes / Entity Schemas

---

# 3.1 app_profile

Stores local user profile and onboarding state.

| Field                 | Type         | Constraints             | Description                                 |
| --------------------- | ------------ | ----------------------- | ------------------------------------------- |
| id                    | String UUID  | required, unique        | Local profile ID                            |
| display_name          | String       | nullable, max 50        | User name                                   |
| user_type             | String       | required                | student, fitness, wellness, senior, working |
| selected_goals        | List<String> | required, default []    | User selected goals                         |
| onboarding_completed  | bool         | required, default false | Whether onboarding is complete              |
| default_step_goal     | int          | required, default 8000  | Daily step target                           |
| default_water_goal_ml | int          | required, default 2500  | Daily water target                          |
| created_at            | DateTime     | required                | Created timestamp                           |
| updated_at            | DateTime     | required                | Updated timestamp                           |

## Indexes

| Index   | Field                |
| ------- | -------------------- |
| primary | id                   |
| query   | onboarding_completed |
| query   | user_type            |

---

# 3.2 habits

Stores user-created habits.

| Field            | Type        | Constraints             | Description                              |
| ---------------- | ----------- | ----------------------- | ---------------------------------------- |
| id               | String UUID | required, unique        | Habit ID                                 |
| title            | String      | required, 2–40 chars    | Habit name                               |
| category         | String      | required                | health, study, fitness, wellness, custom |
| type             | String      | required                | checkbox, counter, timer, quantity       |
| frequency        | String      | required                | daily, weekly                            |
| target_value     | double      | nullable                | Target count/time/quantity               |
| unit             | String      | nullable                | ml, steps, minutes, reps                 |
| icon             | String      | nullable                | Icon key                                 |
| color_hex        | String      | required                | Habit color                              |
| reminder_enabled | bool        | required, default false | Reminder status                          |
| reminder_time    | String      | nullable                | HH:mm                                    |
| is_archived      | bool        | required, default false | Soft delete flag                         |
| created_at       | DateTime    | required                | Created timestamp                        |
| updated_at       | DateTime    | required                | Updated timestamp                        |

## Indexes

| Index   | Field       |
| ------- | ----------- |
| primary | id          |
| query   | category    |
| query   | frequency   |
| query   | is_archived |

## Relationships

```text
habits 1 → many habit_logs
```

---

# 3.3 habit_logs

Stores daily habit completion.

| Field           | Type        | Constraints          | Description                   |
| --------------- | ----------- | -------------------- | ----------------------------- |
| id              | String UUID | required, unique     | Log ID                        |
| habit_id        | String UUID | required             | References habits.id          |
| log_date        | String      | required, YYYY-MM-DD | Completion date               |
| status          | String      | required             | completed, missed, skipped    |
| completed_value | double      | nullable             | Completed count/time/quantity |
| note            | String      | nullable, max 255    | Optional note                 |
| created_at      | DateTime    | required             | Created timestamp             |
| updated_at      | DateTime    | required             | Updated timestamp             |

## Indexes

| Index   | Field               |
| ------- | ------------------- |
| primary | id                  |
| foreign | habit_id            |
| query   | log_date            |
| unique  | habit_id + log_date |

## Relationship

```text
habit_logs many → 1 habits
```

## Delete Rule

```text
If habit is deleted, delete related habit_logs.
```

---

# 3.4 water_logs

Stores daily water entries.

| Field      | Type        | Constraints                | Description       |
| ---------- | ----------- | -------------------------- | ----------------- |
| id         | String UUID | required, unique           | Water log ID      |
| log_date   | String      | required, YYYY-MM-DD       | Date              |
| amount_ml  | int         | required, min 1, max 15000 | Water amount      |
| entry_time | DateTime    | required                   | Entry timestamp   |
| created_at | DateTime    | required                   | Created timestamp |
| updated_at | DateTime    | required                   | Updated timestamp |

## Indexes

| Index   | Field      |
| ------- | ---------- |
| primary | id         |
| query   | log_date   |
| query   | entry_time |

---

# 3.5 step_logs

Stores daily step history.

| Field       | Type        | Constraints                  | Description        |
| ----------- | ----------- | ---------------------------- | ------------------ |
| id          | String UUID | required, unique             | Step log ID        |
| log_date    | String      | required, unique, YYYY-MM-DD | Date               |
| steps       | int         | required, min 0              | Total steps        |
| goal_steps  | int         | required, default 8000       | Daily step goal    |
| distance_km | double      | nullable                     | Estimated distance |
| calories    | double      | nullable                     | Estimated calories |
| source      | String      | required                     | pedometer, manual  |
| created_at  | DateTime    | required                     | Created timestamp  |
| updated_at  | DateTime    | required                     | Updated timestamp  |

## Indexes

| Index   | Field    |
| ------- | -------- |
| primary | id       |
| unique  | log_date |

---

# 3.6 meal_logs

Stores meal completion records.

| Field          | Type        | Constraints          | Description                             |
| -------------- | ----------- | -------------------- | --------------------------------------- |
| id             | String UUID | required, unique     | Meal log ID                             |
| log_date       | String      | required, YYYY-MM-DD | Date                                    |
| meal_name      | String      | required, max 40     | Breakfast, lunch, dinner, custom        |
| meal_type      | String      | required             | breakfast, lunch, dinner, snack, custom |
| status         | String      | required             | completed, skipped, delayed             |
| planned_time   | String      | nullable, HH:mm      | Planned meal time                       |
| completed_time | DateTime    | nullable             | Completion time                         |
| created_at     | DateTime    | required             | Created timestamp                       |
| updated_at     | DateTime    | required             | Updated timestamp                       |

## Indexes

| Index   | Field                |
| ------- | -------------------- |
| primary | id                   |
| query   | log_date             |
| query   | meal_type            |
| unique  | log_date + meal_name |

---

# 3.7 focus_sessions

Stores study/productivity sessions.

| Field             | Type        | Constraints              | Description                    |
| ----------------- | ----------- | ------------------------ | ------------------------------ |
| id                | String UUID | required, unique         | Focus session ID               |
| category          | String      | required                 | study, coding, reading, custom |
| planned_minutes   | int         | required, min 5, max 180 | Planned duration               |
| completed_minutes | int         | required, min 0          | Completed duration             |
| status            | String      | required                 | completed, cancelled, partial  |
| started_at        | DateTime    | required                 | Start time                     |
| ended_at          | DateTime    | nullable                 | End time                       |
| created_at        | DateTime    | required                 | Created timestamp              |
| updated_at        | DateTime    | required                 | Updated timestamp              |

## Indexes

| Index   | Field      |
| ------- | ---------- |
| primary | id         |
| query   | category   |
| query   | started_at |
| query   | status     |

---

# 3.8 sleep_logs

Stores manual sleep records.

| Field         | Type        | Constraints          | Description                 |
| ------------- | ----------- | -------------------- | --------------------------- |
| id            | String UUID | required, unique     | Sleep log ID                |
| sleep_date    | String      | required, YYYY-MM-DD | Sleep date                  |
| sleep_time    | DateTime    | required             | Sleep start                 |
| wake_time     | DateTime    | required             | Wake time                   |
| total_minutes | int         | required, min 0      | Calculated sleep duration   |
| quality       | String      | nullable             | poor, okay, good, excellent |
| created_at    | DateTime    | required             | Created timestamp           |
| updated_at    | DateTime    | required             | Updated timestamp           |

## Indexes

| Index   | Field      |
| ------- | ---------- |
| primary | id         |
| unique  | sleep_date |

---

# 3.9 mood_logs

Stores daily mood.

| Field      | Type        | Constraints                  | Description                   |
| ---------- | ----------- | ---------------------------- | ----------------------------- |
| id         | String UUID | required, unique             | Mood log ID                   |
| log_date   | String      | required, unique, YYYY-MM-DD | Date                          |
| mood       | String      | required                     | great, good, okay, bad, tired |
| note       | String      | nullable, max 255            | Optional mood note            |
| created_at | DateTime    | required                     | Created timestamp             |
| updated_at | DateTime    | required                     | Updated timestamp             |

## Indexes

| Index   | Field    |
| ------- | -------- |
| primary | id       |
| unique  | log_date |
| query   | mood     |

---

# 3.10 rewards

Stores reward definitions and unlock state.

| Field            | Type        | Constraints             | Description                 |
| ---------------- | ----------- | ----------------------- | --------------------------- |
| id               | String UUID | required, unique        | Reward ID                   |
| title            | String      | required, max 50        | Reward title                |
| description      | String      | required, max 255       | Reward description          |
| reward_type      | String      | required                | badge, theme, streak, frame |
| unlock_condition | String      | required                | Condition key               |
| unlocked_at      | DateTime    | nullable                | Unlock timestamp            |
| is_unlocked      | bool        | required, default false | Unlock status               |
| created_at       | DateTime    | required                | Created timestamp           |
| updated_at       | DateTime    | required                | Updated timestamp           |

## Indexes

| Index   | Field       |
| ------- | ----------- |
| primary | id          |
| query   | reward_type |
| query   | is_unlocked |

---

# 3.11 app_settings

Stores app preferences.

| Field                  | Type        | Constraints              | Description           |
| ---------------------- | ----------- | ------------------------ | --------------------- |
| id                     | String UUID | required, unique         | Settings ID           |
| theme_mode             | String      | required, default system | light, dark, system   |
| accent_color           | String      | required                 | Hex color             |
| notifications_enabled  | bool        | required, default true   | Notification status   |
| step_tracking_enabled  | bool        | required, default false  | Step tracking status  |
| reduced_motion_enabled | bool        | required, default false  | Accessibility setting |
| created_at             | DateTime    | required                 | Created timestamp     |
| updated_at             | DateTime    | required                 | Updated timestamp     |

---

# 4. API Endpoints

## V1 Decision

LifeGrid V1 has **no HTTP API endpoints**.

The following are intentionally not built:

```text
POST /auth/register
POST /auth/login
POST /auth/logout
POST /auth/refresh
GET /habits
POST /habits
PATCH /habits/:id
DELETE /habits/:id
```

Reason:

```text
No backend server exists in V1.
All CRUD happens locally inside the app.
```

---

# 5. Local Repository Actions

Instead of API endpoints, use repository methods.

---

## 5.1 Habit Repository

```dart
createHabit(Habit habit)
updateHabit(Habit habit)
archiveHabit(String habitId)
deleteHabit(String habitId)
getActiveHabits()
completeHabit(String habitId, DateTime date)
getHabitLogsByDate(DateTime date)
```

## Error Cases

| Error Code            | When                               |
| --------------------- | ---------------------------------- |
| habit_title_required  | Title is empty                     |
| habit_title_too_short | Title under 2 characters           |
| habit_title_too_long  | Title over 40 characters           |
| habit_not_found       | Habit ID does not exist            |
| duplicate_habit_log   | Same habit completed for same date |

---

## 5.2 Water Repository

```dart
addWaterLog(int amountMl)
removeWaterLog(String logId)
getWaterTotalByDate(DateTime date)
getWaterLogsByDate(DateTime date)
```

## Validation

| Field       | Rule                    |
| ----------- | ----------------------- |
| amount_ml   | 1–15000                 |
| daily_total | must not exceed 15000ml |

## Error Message

```text
Invalid water amount.
```

---

## 5.3 Step Repository

```dart
saveDailySteps(DateTime date, int steps)
getStepsByDate(DateTime date)
getStepHistory(DateTime start, DateTime end)
```

## Validation

| Field      | Rule       |
| ---------- | ---------- |
| steps      | 0–100000   |
| goal_steps | 500–100000 |

---

## 5.4 Focus Repository

```dart
startFocusSession(FocusSession session)
completeFocusSession(String sessionId)
cancelFocusSession(String sessionId)
getFocusSessionsByDate(DateTime date)
```

## Validation

| Field             | Rule  |
| ----------------- | ----- |
| planned_minutes   | 5–180 |
| completed_minutes | 0–180 |

---

# 6. Authentication

## V1 Auth

```json
{
  "authEnabled": false,
  "reason": "LifeGrid V1 is offline-only and does not require accounts."
}
```

## JWT Payload

Not applicable.

```json
{
  "accessToken": "not_used",
  "refreshToken": "not_used"
}
```

## Password Hashing

Not applicable.

```json
{
  "bcryptRounds": 0,
  "reason": "No passwords are stored."
}
```

## Authorization Levels

| Level             | Route Examples  |
| ----------------- | --------------- |
| Public Local User | All app screens |
| Admin             | Not used        |
| Guest             | Not used        |

---

# 7. Standard Local Error Format

Even without APIs, use a consistent app error object.

```json
{
  "success": false,
  "error": {
    "code": "habit_not_found",
    "message": "Habit could not be found.",
    "details": {
      "habitId": "uuid"
    }
  }
}
```

## Error Code Mapping

| Code                    | UI Message                                  |
| ----------------------- | ------------------------------------------- |
| habit_not_found         | Habit could not be found.                   |
| invalid_water_amount    | Invalid water amount.                       |
| step_sensor_unavailable | Step tracking unavailable on this device.   |
| permission_denied       | Permission is required to use this feature. |
| storage_write_failed    | Unable to save progress. Please try again.  |
| backup_corrupted        | Backup file is invalid or corrupted.        |
| timer_already_running   | A focus timer is already running.           |

---

# 8. Caching Strategy

## V1 Cache Layers

| Layer                    | Used For                 | TTL               |
| ------------------------ | ------------------------ | ----------------- |
| Riverpod in-memory state | Current dashboard values | Until app restart |
| Hive local DB            | Persistent records       | Permanent         |
| SharedPreferences        | Small settings           | Permanent         |

## Cache Keys

```text
dashboard_today_YYYY_MM_DD
water_total_YYYY_MM_DD
habit_logs_YYYY_MM_DD
step_total_YYYY_MM_DD
focus_sessions_YYYY_MM_DD
```

## Invalidation Rules

| Action                  | Invalidate                      |
| ----------------------- | ------------------------------- |
| Habit completed         | dashboard_today, habit_logs     |
| Water added             | dashboard_today, water_total    |
| Steps updated           | dashboard_today, step_total     |
| Focus session completed | dashboard_today, focus_sessions |
| Sleep logged            | dashboard_today                 |
| Mood logged             | dashboard_today                 |

---

# 9. Rate Limiting

No server rate limiting is required.

Use local interaction protection instead.

| Action                  | Limit                         |
| ----------------------- | ----------------------------- |
| Habit completion tap    | Debounce 500ms                |
| Water quick-add tap     | Debounce 300ms                |
| Timer start             | Only 1 active timer           |
| Backup restore          | 1 restore operation at a time |
| Notification scheduling | Max 64 active reminders       |

---

# 10. Migration Strategy

## Tool

Hive manual migration using schema version.

```dart
const int localSchemaVersion = 1;
```

## Migration Process

```text
1. Read current local schema version
2. Compare with app schema version
3. If old version found, run migration scripts
4. Backup old boxes before migration
5. Write new schema version after success
6. If migration fails, restore backup
```

## Migration Example

```dart
Future<void> runMigrations() async {
  final currentVersion = settingsBox.get('schema_version', defaultValue: 1);

  if (currentVersion < 2) {
    await migrateV1ToV2();
    await settingsBox.put('schema_version', 2);
  }
}
```

## Rollback Strategy

```text
If migration fails:
- stop migration
- restore previous local backup
- show error screen
- allow user to retry
```

## Error Message

```text
Some local data could not be upgraded. Please restore backup or retry.
```

---

# 11. What Is Explicitly Not Built

These backend features are not part of V1:

1. Server database
2. Node.js API
3. Login/register
4. JWT authentication
5. Refresh tokens
6. Admin panel
7. Cloud sync
8. Email verification
9. Password reset
10. Redis caching
11. Webhooks
12. Payment system
13. Multi-device sync

---

# 12. Future Backend Option

Only consider backend in V2 if user needs:

* cloud backup
* multi-device sync
* login
* family sharing
* admin dashboard
* premium subscription

Recommended V2 backend:

```text
Supabase
PostgreSQL
Supabase Auth
Supabase Storage
Edge Functions
```

But do **not** add this in V1.
