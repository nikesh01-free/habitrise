import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_text_styles.dart';

class OfflineBannerWidget extends StatefulWidget {
  const OfflineBannerWidget({super.key});

  @override
  State<OfflineBannerWidget> createState() => _OfflineBannerWidgetState();
}

class _OfflineBannerWidgetState extends State<OfflineBannerWidget> {
  bool _isVisible = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissed = prefs.getBool('offline_banner_dismissed') ?? false;
    if (mounted) {
      setState(() {
        _isVisible = !dismissed;
        _isInitialized = true;
      });
    }
  }

  Future<void> _dismissBanner() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offline_banner_dismissed', true);
    if (mounted) {
      setState(() {
        _isVisible = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || !_isVisible) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        height: 36, // 32px content + padding
        color: isDark ? const Color(0xFF4A3E1E) : const Color(0xFFFFF9E6),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.amber,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Running in offline-only mode. All data is saved locally.',
                style: AppTextStyles.bodyS.copyWith(
                  color: isDark ? Colors.amber[100] : const Color(0xFF664D03),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: _dismissBanner,
              child: Icon(
                Icons.close_rounded,
                color: isDark ? Colors.amber[100] : const Color(0xFF664D03),
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
