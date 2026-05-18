# FRONTEND_GUIDELINES.md — LifeGrid

## App Name

**LifeGrid**

## App Style

Modern, minimal, bold, wellness-focused, professional.

## Target Audience

Students, gym users, working professionals, women, and seniors who want a simple offline app for habits, water, steps, meals, sleep, focus, and personal growth.

---

# 1. Design Principles

## 1.1 Progress Must Be Visible

Every screen should show clear progress:

- completed habits
- water percentage
- step goal
- streak
- focus time

## 1.2 One-Hand Friendly

Primary actions must be reachable near the lower half of the screen.

## 1.3 Low Cognitive Load

Avoid crowded forms. Use cards, icons, progress rings, and simple labels.

## 1.4 Offline Confidence

The UI must never feel broken without internet.

## 1.5 Reward-Based Motivation

Use animations, badges, streaks, and micro-feedback after user actions.

---

# 2. Design Tokens

## 2.1 Primary Color Scale

```dart
class AppColors {
  static const primary50 = Color(0xFFEFF6FF);
  static const primary100 = Color(0xFFDBEAFE);
  static const primary200 = Color(0xFFBFDBFE);
  static const primary300 = Color(0xFF93C5FD);
  static const primary400 = Color(0xFF60A5FA);
  static const primary500 = Color(0xFF3B82F6);
  static const primary600 = Color(0xFF2563EB);
  static const primary700 = Color(0xFF1D4ED8);
  static const primary800 = Color(0xFF1E40AF);
  static const primary900 = Color(0xFF1E3A8A);
}
```

### Usage

| Color          | Usage                 |
| -------------- | --------------------- |
| primary50–100  | Soft backgrounds      |
| primary300–400 | Highlights            |
| primary500     | Main buttons          |
| primary600     | Button pressed        |
| primary700–900 | Headers, dark accents |

---

## 2.2 Neutral Color Scale

```dart
class AppNeutral {
  static const neutral50 = Color(0xFFF8FAFC);
  static const neutral100 = Color(0xFFF1F5F9);
  static const neutral200 = Color(0xFFE2E8F0);
  static const neutral300 = Color(0xFFCBD5E1);
  static const neutral400 = Color(0xFF94A3B8);
  static const neutral500 = Color(0xFF64748B);
  static const neutral600 = Color(0xFF475569);
  static const neutral700 = Color(0xFF334155);
  static const neutral800 = Color(0xFF1E293B);
  static const neutral900 = Color(0xFF0F172A);
}
```

### Usage

| Color      | Usage           |
| ---------- | --------------- |
| neutral50  | App background  |
| neutral100 | Card background |
| neutral300 | Borders         |
| neutral500 | Secondary text  |
| neutral700 | Body text       |
| neutral900 | Headings        |

---

## 2.3 Semantic Colors

```dart
class AppSemantic {
  static const success = Color(0xFF22C55E);
  static const successLight = Color(0xFFDCFCE7);

  static const warning = Color(0xFFF59E0B);
  static const warningLight = Color(0xFFFEF3C7);

  static const error = Color(0xFFEF4444);
  static const errorLight = Color(0xFFFEE2E2);

  static const info = Color(0xFF06B6D4);
  static const infoLight = Color(0xFFCFFAFE);
}
```

### Usage

| Color   | Usage                           |
| ------- | ------------------------------- |
| Success | Completed habits, goal achieved |
| Warning | Missed meal, incomplete day     |
| Error   | Failed save, invalid input      |
| Info    | Tips, reminders, neutral alerts |

---

## 2.4 Typography

Use **Inter** or **Poppins**.

```dart
class AppTextStyles {
  static const fontFamily = 'Inter';

  static const displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const heading3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static const bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.45,
  );

  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
```

---

## 2.5 Spacing Scale

```dart
class AppSpacing {
  static const s0 = 0.0;
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s7 = 28.0;
  static const s8 = 32.0;
  static const s9 = 36.0;
  static const s10 = 40.0;
  static const s11 = 44.0;
  static const s12 = 48.0;
  static const s13 = 52.0;
  static const s14 = 56.0;
  static const s15 = 60.0;
  static const s16 = 64.0;
}
```

---

## 2.6 Border Radius

```dart
class AppRadius {
  static const none = Radius.circular(0);
  static const xs = Radius.circular(4);
  static const sm = Radius.circular(8);
  static const md = Radius.circular(12);
  static const lg = Radius.circular(16);
  static const xl = Radius.circular(20);
  static const xxl = Radius.circular(24);
  static const full = Radius.circular(999);
}
```

---

## 2.7 Shadows

```dart
class AppShadows {
  static const level1 = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.06),
    blurRadius: 8,
    offset: Offset(0, 2),
  );

  static const level2 = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.08),
    blurRadius: 12,
    offset: Offset(0, 4),
  );

  static const level3 = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.10),
    blurRadius: 18,
    offset: Offset(0, 8),
  );

  static const level4 = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.14),
    blurRadius: 24,
    offset: Offset(0, 12),
  );

  static const level5 = BoxShadow(
    color: Color.fromRGBO(15, 23, 42, 0.18),
    blurRadius: 32,
    offset: Offset(0, 16),
  );
}
```

---

# 3. Component Library

---

# 3.1 Button

## Variants

- Primary
- Secondary
- Outline
- Ghost
- Danger

## Sizes

- Small
- Medium
- Large

```dart
enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
}

enum AppButtonSize {
  sm,
  md,
  lg,
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.isLoading = false,
    this.icon,
  });

  Color get backgroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
        return AppColors.primary500;
      case AppButtonVariant.secondary:
        return AppNeutral.neutral100;
      case AppButtonVariant.outline:
        return Colors.transparent;
      case AppButtonVariant.ghost:
        return Colors.transparent;
      case AppButtonVariant.danger:
        return AppSemantic.error;
    }
  }

  Color get foregroundColor {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.secondary:
      case AppButtonVariant.outline:
      case AppButtonVariant.ghost:
        return AppNeutral.neutral800;
    }
  }

  double get height {
    switch (size) {
      case AppButtonSize.sm:
        return 40;
      case AppButtonSize.md:
        return 48;
      case AppButtonSize.lg:
        return 56;
    }
  }

  EdgeInsets get padding {
    switch (size) {
      case AppButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 14);
      case AppButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 18);
      case AppButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 22);
    }
  }

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || isLoading;

    return Semantics(
      button: true,
      enabled: !disabled,
      label: label,
      child: SizedBox(
        height: height,
        child: ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            disabledBackgroundColor: AppNeutral.neutral200,
            disabledForegroundColor: AppNeutral.neutral400,
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(AppRadius.lg),
              side: variant == AppButtonVariant.outline
                  ? const BorderSide(color: AppNeutral.neutral300)
                  : BorderSide.none,
            ),
          ),
          child: isLoading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foregroundColor,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(label, style: AppTextStyles.button),
                  ],
                ),
        ),
      ),
    );
  }
}
```

### Usage Rules

| Variant   | Use Case                        |
| --------- | ------------------------------- |
| Primary   | Main screen action              |
| Secondary | Less important action           |
| Outline   | Alternative action              |
| Ghost     | Minimal action                  |
| Danger    | Delete/reset/destructive action |

### States

| State    | Behavior                             |
| -------- | ------------------------------------ |
| Default  | Normal clickable                     |
| Hover    | Slight color darkening on web/tablet |
| Focus    | Blue outline                         |
| Disabled | Grey background                      |
| Loading  | Spinner replaces label               |
| Error    | Use danger variant                   |

---

# 3.2 Input

```dart
class AppInput extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? errorText;
  final TextInputType keyboardType;
  final bool enabled;
  final bool obscureText;

  const AppInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.errorText,
    this.keyboardType = TextInputType.text,
    this.enabled = true,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: label,
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: AppTextStyles.bodyLarge.copyWith(
          color: AppNeutral.neutral900,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          errorText: errorText,
          filled: true,
          fillColor: enabled ? Colors.white : AppNeutral.neutral100,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
            borderSide: const BorderSide(color: AppNeutral.neutral300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
            borderSide: const BorderSide(color: AppNeutral.neutral300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
            borderSide: const BorderSide(
              color: AppColors.primary500,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
            borderSide: const BorderSide(
              color: AppSemantic.error,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(AppRadius.md),
            borderSide: const BorderSide(color: AppNeutral.neutral200),
          ),
        ),
      ),
    );
  }
}
```

### Validation Rules

| Field          | Rule             | Error Message                                       |
| -------------- | ---------------- | --------------------------------------------------- |
| Habit name     | 2–40 characters  | “Habit name must be 2–40 characters.”               |
| Water goal     | 500–15000 ml     | “Water goal must be between 500ml and 15000ml.”     |
| Step goal      | 500–100000 steps | “Step goal must be between 500 and 100000 steps.”   |
| Focus duration | 5–180 minutes    | “Focus duration must be between 5 and 180 minutes.” |

---

# 3.3 Card

```dart
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final bool selected;
  final bool error;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.selected = false,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = error
        ? AppSemantic.error
        : selected
            ? AppColors.primary500
            : AppNeutral.neutral200;

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.all(AppRadius.xl),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(AppRadius.xl),
            border: Border.all(color: borderColor),
            boxShadow: const [AppShadows.level1],
          ),
          child: child,
        ),
      ),
    );
  }
}
```

### Variants

| Variant   | Use                          |
| --------- | ---------------------------- |
| Default   | Normal content               |
| Selected  | Goal/habit selected          |
| Error     | Invalid card state           |
| Clickable | Navigates or performs action |

---

# 3.4 Modal

```dart
class AppModal extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;
  final bool isLoading;

  const AppModal({
    super.key,
    required this.title,
    this.description,
    required this.child,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(AppRadius.xxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          scopesRoute: true,
          namesRoute: true,
          label: title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: AppTextStyles.heading2),
              if (description != null) ...[
                const SizedBox(height: 8),
                Text(
                  description!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppNeutral.neutral500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              child,
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: secondaryLabel,
                      variant: AppButtonVariant.secondary,
                      onPressed: onSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: primaryLabel,
                      isLoading: isLoading,
                      onPressed: onPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Usage

Use modal for:

- delete confirmation
- reset day
- restore backup
- permission explanation

Do not use modal for:

- normal navigation
- full forms longer than 5 fields

---

# 3.5 Alert / Toast

```dart
enum AppToastType {
  success,
  warning,
  error,
  info,
}

class AppToast extends StatelessWidget {
  final String message;
  final AppToastType type;

  const AppToast({
    super.key,
    required this.message,
    required this.type,
  });

  Color get background {
    switch (type) {
      case AppToastType.success:
        return AppSemantic.successLight;
      case AppToastType.warning:
        return AppSemantic.warningLight;
      case AppToastType.error:
        return AppSemantic.errorLight;
      case AppToastType.info:
        return AppSemantic.infoLight;
    }
  }

  Color get foreground {
    switch (type) {
      case AppToastType.success:
        return AppSemantic.success;
      case AppToastType.warning:
        return AppSemantic.warning;
      case AppToastType.error:
        return AppSemantic.error;
      case AppToastType.info:
        return AppSemantic.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.all(AppRadius.lg),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: foreground),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppNeutral.neutral900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Toast Messages

| Case              | Message                                       |
| ----------------- | --------------------------------------------- |
| Habit complete    | “Habit completed.”                            |
| Save failed       | “Unable to save progress. Please try again.”  |
| Permission denied | “Permission is required to use this feature.” |
| Invalid input     | “Please enter a valid value.”                 |

---

# 3.6 Loading States

```dart
class AppLoadingState extends StatelessWidget {
  final String message;

  const AppLoadingState({
    super.key,
    this.message = 'Loading...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        label: message,
        liveRegion: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: AppColors.primary500,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppNeutral.neutral500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Loading Usage

Use for:

- opening dashboard
- loading analytics
- restoring backup
- reading sensor state

Do not show loading longer than 3 seconds without fallback text.

---

# 3.7 Empty States

```dart
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Semantics(
          label: title,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 56, color: AppColors.primary500),
              const SizedBox(height: 16),
              Text(title, style: AppTextStyles.heading3),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppNeutral.neutral500,
                ),
              ),
              const SizedBox(height: 20),
              AppButton(
                label: buttonLabel,
                onPressed: onPressed,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Empty State Examples

| Screen    | Title                     | Button            |
| --------- | ------------------------- | ----------------- |
| Habits    | “No habits yet”           | “Create Habit”    |
| Analytics | “No progress data yet”    | “Start Tracking”  |
| Meals     | “No meals added”          | “Add Meal”        |
| Rewards   | “No rewards unlocked yet” | “Complete Habits” |

---

# 4. Layout System

## 4.1 Grid

| Device  | Max Width | Columns | Gutter |
| ------- | --------: | ------: | -----: |
| Mobile  |      100% |       4 |   16px |
| Tablet  |     720px |       8 |   20px |
| Desktop |    1120px |      12 |   24px |

---

## 4.2 Breakpoints

```dart
class AppBreakpoints {
  static const mobile = 0.0;
  static const tablet = 768.0;
  static const desktop = 1024.0;
  static const largeDesktop = 1280.0;
}
```

---

## 4.3 Centered Content

```dart
class CenteredContent extends StatelessWidget {
  final Widget child;

  const CenteredContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
```

---

## 4.4 Two-Column Layout

```dart
class TwoColumnLayout extends StatelessWidget {
  final Widget left;
  final Widget right;

  const TwoColumnLayout({
    super.key,
    required this.left,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).width >= 768;

    if (!isTablet) {
      return Column(
        children: [
          left,
          const SizedBox(height: 16),
          right,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 20),
        Expanded(child: right),
      ],
    );
  }
}
```

---

## 4.5 Sidebar Layout

```dart
class SidebarLayout extends StatelessWidget {
  final Widget sidebar;
  final Widget content;

  const SidebarLayout({
    super.key,
    required this.sidebar,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.sizeOf(context).width >= 1024;

    if (!isDesktop) {
      return content;
    }

    return Row(
      children: [
        SizedBox(
          width: 280,
          child: sidebar,
        ),
        Expanded(child: content),
      ],
    );
  }
}
```

---

# 5. Accessibility

## Requirements

- Minimum touch target: **44x44 px**
- Text contrast: WCAG 2.1 AA
- All buttons must have semantic labels
- Inputs must have labels
- Error messages must be visible and readable
- Color must not be the only status indicator
- Support dynamic font scaling
- Support screen readers

## Focus Rules

- Focus border must use `primary500`
- Focus indicator must be at least 2px
- Keyboard navigation must follow screen order

## Error Message Rules

Bad:

```text
Invalid
```

Good:

```text
Water goal must be between 500ml and 15000ml.
```

---

# 6. Animation Guidelines

## Duration

```dart
class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}
```

## Easing

```dart
class AppCurves {
  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubic;
}
```

## Animate

- habit completion
- reward unlock
- progress ring update
- water fill
- step goal completion
- modal entrance
- toast entrance

## Do Not Animate

- long text
- validation errors aggressively
- every list item on large lists
- critical error messages

## Reduced Motion

If user enables reduced motion:

- disable confetti
- disable large scale animations
- keep opacity transitions under 150ms

```dart
final disableAnimations =
    MediaQuery.of(context).disableAnimations;

final duration = disableAnimations
    ? Duration.zero
    : AppDurations.normal;
```

---

# 7. Final UI Direction

LifeGrid should feel:

- calm
- fast
- clean
- motivational
- offline-safe

Avoid:

- too many colors
- heavy gradients everywhere
- tiny text
- crowded dashboards
- complex charts on home screen
- social-media-style UI

The strongest interface is a **daily control center** with clear progress cards, quick actions, and rewarding feedback.
