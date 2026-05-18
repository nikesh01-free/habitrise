import 'package:intl/intl.dart';

class AppDateUtils {
  /// Standardizes canonical today key format
  static String todayDateKey() {
    return dateToKey(DateTime.now());
  }

  /// Converts arbitrary date into universal persistent key YYYY-MM-DD
  static String dateToKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  /// Evaluates if two timestamps denote the same physical calendar day
  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Normalizes 24H time presentation safely
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  /// Normalizes user-readable chronological label
  static String formatDateLabel(DateTime date) {
    final now = DateTime.now();
    if (isSameDate(date, now)) {
      return 'Today';
    }
    if (isSameDate(date, now.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
