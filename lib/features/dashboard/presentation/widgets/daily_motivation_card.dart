import 'package:flutter/material.dart';
import 'package:habitrise/core/theme/app_text_styles.dart';
import 'package:habitrise/core/theme/app_radius.dart';

class DailyMotivationCard extends StatelessWidget {
  const DailyMotivationCard({super.key});

  static const List<String> _quotes = [
    "The only bad workout is the one that didn't happen.",
    "Small daily improvements lead to stunning results.",
    "Discipline is doing what needs to be done, even if you don't want to.",
    "Success is the sum of small efforts repeated day-in and day-out.",
    "You don't have to be extreme, just consistent.",
    "Motivation gets you started. Habit keeps you going.",
    "Your future self will thank you for today's effort.",
    "Every action you take is a vote for the person you want to become.",
    "Progress, not perfection.",
    "The secret of your future is hidden in your daily routine.",
    "Believe you can and you're halfway there.",
    "Action is the foundational key to all success.",
    "Make each day your masterpiece.",
    "Dream big. Start small. But most importantly, start.",
    "Be stronger than your excuses.",
    "The best time to start was yesterday. The next best time is now.",
    "Your only limit is your mind.",
    "A year from now you may wish you had started today.",
    "Don't stop until you're proud.",
    "It always seems impossible until it's done.",
  ];

  String _getDailyQuote() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    return _quotes[dayOfYear % _quotes.length];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final quote = _getDailyQuote();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF667EEA).withAlpha(40), const Color(0xFF764BA2).withAlpha(30)]
              : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.cardRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withAlpha(isDark ? 30 : 50),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withAlpha(30) : Colors.white.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.format_quote_rounded,
              color: isDark ? Colors.white70 : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          // Quote content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Insight',
                  style: AppTextStyles.bodyS.copyWith(
                    color: isDark ? Colors.white70 : Colors.white70,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '"$quote"',
                  style: AppTextStyles.bodyM.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}