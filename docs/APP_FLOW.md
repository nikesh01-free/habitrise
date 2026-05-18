# APP_FLOW.md — LifeGrid

# Product Name

**LifeGrid**

# Product Description

LifeGrid is an offline-first personal growth and habit tracking mobile application focused on:

- habit consistency
- wellness tracking
- productivity
- hydration
- sleep
- fitness
- focus management

The app targets students, gym users, working professionals, women, and seniors who want to improve discipline and healthy routines without requiring internet connectivity.

---

# 1. Entry Points

Users can enter the application through the following entry points:

| Entry Point              | Trigger                           |
| ------------------------ | --------------------------------- |
| App Icon Tap             | User opens app normally           |
| Local Notification       | Reminder notification tap         |
| Deep Link (Future Ready) | Opens specific screen             |
| Background Restore       | App restored from background      |
| System Restart Recovery  | App auto-restores previous state  |
| Focus Timer Notification | Timer completion notification tap |

---

# 2. Core User Flows

---

# FLOW 1 — First-Time Onboarding Flow

## Goal

Help new users configure goals and initial habits quickly.

---

## Happy Path

### Step 1 — Splash Screen

**Page:** `/splash`

### Elements

- Logo
- Loading animation

### System Response

- Check onboarding completion status.

### Next Step

IF onboarding incomplete → `/onboarding/welcome`
ELSE → `/dashboard`

---

### Step 2 — Welcome Screen

**Page:** `/onboarding/welcome`

### Elements

- Welcome message
- “Get Started” button

### User Action

Tap “Get Started”

### System Response

Navigate to goal selection.

### Next Step

`/onboarding/goals`

---

### Step 3 — Goal Selection

**Page:** `/onboarding/goals`

### Elements

- Student
- Fitness
- Productivity
- Better Sleep
- Wellness

### Validation Rules

- Minimum 1 goal required

### Error Message

“Please select at least one goal.”

### User Action

Select goals → Continue

### System Response

Generate starter habits.

### Next Step

`/onboarding/habits`

---

### Step 4 — Starter Habits

**Page:** `/onboarding/habits`

### Elements

- Suggested habits
- Edit/Delete buttons
- Add custom habit

### User Action

Confirm habits

### System Response

Save habits locally.

### Next Step

`/onboarding/permissions`

---

### Step 5 — Permissions

**Page:** `/onboarding/permissions`

### Elements

- Step tracking permission
- Notification permission

### User Action

Allow or deny permissions

### System Response

Store permission state.

### Next Step

`/dashboard`

---

## Error States

| Error                     | Behavior                           |
| ------------------------- | ---------------------------------- |
| No goals selected         | Prevent continue                   |
| Permission denied         | Show limited functionality message |
| App closed mid-onboarding | Resume last onboarding screen      |

---

## Edge Cases

| Edge Case                           | Handling                            |
| ----------------------------------- | ----------------------------------- |
| User presses back during onboarding | Show confirmation dialog            |
| App crashes during onboarding       | Restore previous onboarding step    |
| User skips permissions              | Features remain disabled gracefully |

---

# FLOW 2 — Habit Completion Flow

## Goal

Allow users to complete habits quickly.

---

## Happy Path

### Step 1 — Open Dashboard

**Page:** `/dashboard`

### Elements

- Habit cards
- Progress ring
- Daily summary

### User Action

Tap incomplete habit checkbox.

### System Response

- Mark habit completed
- Update streak
- Trigger animation
- Save locally

### Next Step

Dashboard refreshes instantly.

---

## Error States

| Error                  | Behavior                  |
| ---------------------- | ------------------------- |
| Database write failure | Retry automatically       |
| Duplicate completion   | Prevent second completion |
| Invalid habit state    | Reset to last valid state |

### Error Message

“Unable to save progress. Please try again.”

---

## Edge Cases

| Edge Case                        | Handling                          |
| -------------------------------- | --------------------------------- |
| User changes device date         | Validate against previous entries |
| User taps rapidly multiple times | Debounce tap input                |
| Habit already completed          | Disable completion button         |

---

# FLOW 3 — Water Tracking Flow

## Goal

Allow fast hydration logging.

---

## Happy Path

### Step 1 — Open Water Widget

**Page:** `/dashboard`

### Elements

- Water progress bar
- Quick add buttons

### User Action

Tap `+250ml`

### System Response

- Add water amount
- Update hydration percentage
- Save locally

### Next Step

Dashboard refreshes.

---

## Validation Rules

| Rule                               | Condition               |
| ---------------------------------- | ----------------------- |
| Water amount cannot exceed 15L/day | Prevent invalid entries |
| Negative values not allowed        | Reject input            |

---

## Error Message

“Invalid water amount.”

---

## Edge Cases

| Edge Case               | Handling                      |
| ----------------------- | ----------------------------- |
| Excessive rapid taps    | Queue updates                 |
| Daily reset at midnight | Auto-reset values             |
| App offline             | Continue functioning normally |

---

# FLOW 4 — Focus Timer Flow

## Goal

Track productivity sessions.

---

## Happy Path

### Step 1 — Open Focus Screen

**Page:** `/focus`

### Elements

- Timer presets
- Start button
- Pause button

### User Action

Select 25 minutes → Start

### System Response

- Timer begins
- Background service activated

### Next Step

Live countdown updates.

---

### Step 2 — Session Completion

### System Response

- Save session
- Show completion animation
- Award XP
- Trigger notification

### Next Step

Return to focus summary.

---

## Error States

| Error             | Behavior                   |
| ----------------- | -------------------------- |
| Timer interrupted | Save partial session       |
| App force closed  | Restore timer state        |
| Device sleep mode | Continue background timing |

---

## Edge Cases

| Edge Case                  | Handling                  |
| -------------------------- | ------------------------- |
| User leaves screen         | Timer continues           |
| User changes time manually | Validate elapsed duration |
| Multiple timers started    | Block second timer        |

---

# FLOW 5 — Step Counter Flow

## Goal

Display real-time step activity.

---

## Happy Path

### Step 1 — Permission Check

IF permission granted:

- Load step data

ELSE:

- Show permission request

---

### Step 2 — Sensor Tracking

### System Response

- Read device pedometer
- Update UI automatically

### Next Step

Dashboard refreshes periodically.

---

## Error States

| Error              | Behavior                        |
| ------------------ | ------------------------------- |
| Sensor unavailable | Show unsupported device message |
| Permission denied  | Disable feature gracefully      |
| Data unavailable   | Display last synced count       |

### Error Message

“Step tracking unavailable on this device.”

---

## Edge Cases

| Edge Case            | Handling                   |
| -------------------- | -------------------------- |
| Device reboot        | Resume tracking            |
| Sensor resets        | Recalculate daily baseline |
| No movement detected | Show idle state            |

---

# FLOW 6 — Mood Tracking Flow

---

## Happy Path

### User Action

Select mood emoji.

### System Response

- Save mood
- Update calendar indicator

### Next Step

Return to dashboard.

---

## Validation Rules

- One mood entry per day.

### Error Message

“You have already logged today’s mood.”

---

# FLOW 7 — Analytics Flow

---

## Happy Path

### User Action

Open analytics tab.

### System Response

- Load weekly/monthly charts
- Calculate streaks
- Display summaries

---

## Error States

| Error             | Behavior                   |
| ----------------- | -------------------------- |
| No data available | Show empty analytics state |
| Corrupted records | Skip invalid entries       |

---

# 3. Navigation Map

```text
Splash
│
├── Onboarding
│   ├── Welcome
│   ├── Goal Selection
│   ├── Starter Habits
│   ├── Permissions
│
├── Dashboard
│   ├── Habit Detail
│   ├── Water Tracker
│   ├── Step Counter
│   ├── Mood Tracker
│
├── Focus
│   ├── Timer Running
│   ├── Session Summary
│
├── Calendar
│   ├── Day Details
│
├── Analytics
│
├── Rewards
│
├── Sleep Tracker
│
├── Meal Tracker
│
├── Settings
│   ├── Theme Settings
│   ├── Notification Settings
│   ├── Backup & Restore
│   ├── Permissions
│
└── Error Screens
    ├── Offline State
    ├── Generic Error
```

---

# 4. Screen Inventory

---

# Splash Screen

| Property     | Value                   |
| ------------ | ----------------------- |
| Route        | `/splash`               |
| Access       | Public                  |
| Purpose      | Initial loading         |
| Key Elements | Logo, loading animation |

### Actions

- Auto-navigation

### States

- Loading
- Error

---

# Dashboard

| Property | Value               |
| -------- | ------------------- |
| Route    | `/dashboard`        |
| Access   | Auth-free           |
| Purpose  | Main control center |

### Key Elements

- Progress ring
- Habit cards
- Water tracker
- Step widget
- Mood widget

### Actions

| Action       | Destination     |
| ------------ | --------------- |
| Tap habit    | Complete habit  |
| Tap water    | Open tracker    |
| Tap steps    | Step details    |
| Tap calendar | Calendar screen |

### States

- Loading
- Empty habits
- Success
- Sensor unavailable

---

# Focus Screen

| Property | Value              |
| -------- | ------------------ |
| Route    | `/focus`           |
| Purpose  | Productivity timer |

### States

- Idle
- Running
- Paused
- Completed

---

# Calendar Screen

| Property | Value                    |
| -------- | ------------------------ |
| Route    | `/calendar`              |
| Purpose  | View historical progress |

### States

- Empty
- Data loaded
- Error

---

# Settings Screen

| Property | Value                  |
| -------- | ---------------------- |
| Route    | `/settings`            |
| Purpose  | Preferences management |

---

# 5. Decision Points

---

## Onboarding Logic

```text
IF onboarding_completed = false
THEN show onboarding
ELSE open dashboard
```

---

## Step Tracking

```text
IF permission_granted = true
THEN start sensor tracking
ELSE show permission request
```

---

## Focus Timer

```text
IF timer_running = true
THEN disable additional timers
```

---

## Water Tracking

```text
IF total_water > daily_limit
THEN block additional entries
```

---

## Mood Logging

```text
IF mood_logged_today = true
THEN prevent second mood entry
```

---

# 6. Error Handling

---

# Offline State

## Display

- “You are offline.”
- Local features continue working.

## User Actions

- Retry
- Continue offline

## Recovery

- Auto-reconnect detection

---

# 404 Screen

## Display

“Page not found.”

## Actions

- Go Home
- Back

---

# 500 Generic Error

## Display

“Something went wrong.”

## Actions

- Retry
- Report issue

---

# Database Corruption

## Display

“Some local data could not be loaded.”

## Actions

- Restore backup
- Reset local storage

---

# Permission Denied

## Display

“This feature requires permission access.”

## Actions

- Open settings
- Cancel

---

# 7. Responsive Behavior

---

# Mobile Behavior (Primary)

## Layout

- Bottom navigation
- Swipe interactions
- Full-screen cards

## Optimizations

- One-hand usage
- Large touch targets
- Lightweight animations

---

# Tablet/Desktop Behavior

## Layout

- Side navigation
- Multi-column dashboard
- Expanded analytics

## Differences

- Larger calendar view
- Simultaneous widgets visible
- Wider charts

---

# Final Notes

The application flow prioritizes:

- offline reliability
- fast interactions
- minimal friction
- habit consistency
- emotional engagement

Every critical flow includes:

- success path
- validation handling
- offline behavior
- recovery states
- edge case handling

to ensure predictable and testable user experience.
