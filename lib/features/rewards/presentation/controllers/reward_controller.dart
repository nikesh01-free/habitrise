import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reward_model.dart';
import '../providers/rewards_providers.dart';
import '../../../../core/widgets/app_toast.dart';
import 'package:flutter/material.dart';

final rewardControllerProvider = Provider((ref) => RewardController(ref));

class RewardController {
  final Ref _ref;
  RewardController(this._ref);

  Future<void> checkFirstHabitCompletion(BuildContext? context) async {
    final unlocked = await _unlock('first_habit');
    if (unlocked != null && context != null && context.mounted) {
      AppToast.show(context, '🎉 Badge Earned: ${unlocked.title}!', type: AppToastType.success);
    }
  }

  Future<void> checkFocusMinutes(int totalMinutes, BuildContext? context) async {
    if (totalMinutes >= 100) {
      final unlocked = await _unlock('focus_100m');
      if (unlocked != null && context != null && context.mounted) {
        AppToast.show(context, '🎉 Badge Earned: ${unlocked.title}!', type: AppToastType.success);
      }
    }
  }

  Future<void> checkWaterStreak(int dayStreak, BuildContext? context) async {
    if (dayStreak >= 3) {
      final unlocked = await _unlock('water_goal_3');
      if (unlocked != null && context != null && context.mounted) {
        AppToast.show(context, '🎉 Badge Earned: ${unlocked.title}!', type: AppToastType.success);
      }
    }
  }

  Future<void> checkHabitStreak(int currentStreak, BuildContext? context) async {
    if (currentStreak >= 3) {
      final captured = context;
      final unlocked = await _unlock('streak_3');
      if (unlocked != null && captured != null && captured.mounted) {
        AppToast.show(captured, '🎉 Badge Earned: ${unlocked.title}!', type: AppToastType.success);
      }
    }
    if (currentStreak >= 7) {
      final captured = context;
      final unlocked = await _unlock('streak_7');
      if (unlocked != null && captured != null && captured.mounted) {
        AppToast.show(captured, '🎉 Badge Earned: ${unlocked.title}!', type: AppToastType.success);
      }
    }
  }

  Future<RewardModel?> _unlock(String rewardId) async {
    final repo = _ref.read(rewardsRepositoryProvider);
    final all = repo.getAllRewards();
    final match = all.where((r) => r.id == rewardId).firstOrNull;
    if (match != null && !match.isUnlocked) {
      await repo.unlockReward(rewardId);
      _ref.invalidate(allRewardsProvider);
      return match;
    }
    return null;
  }
}