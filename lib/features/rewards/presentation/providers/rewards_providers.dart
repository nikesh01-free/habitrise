import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/reward_model.dart';
import '../../data/repositories/rewards_repository.dart';

final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  return RewardsRepository();
});

final allRewardsProvider = FutureProvider<List<RewardModel>>((ref) async {
  final repo = ref.watch(rewardsRepositoryProvider);

  // Seed if box is empty
  final current = repo.getAllRewards();
  if (current.isEmpty) {
    await repo.initDefaultRewards(defaultRewards);
    return repo.getAllRewards();
  }

  return current;
});

final defaultRewards = [
  RewardModel(
    id: 'first_habit',
    title: 'Day One Pioneer',
    description: 'Complete your very first habit check-in.',
    rewardType: 'badge',
    unlockCondition: 'habit_count_1',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  RewardModel(
    id: 'streak_3',
    title: 'Three\'s Company',
    description: 'Maintain a habit for 3 consecutive days.',
    rewardType: 'streak',
    unlockCondition: 'streak_3',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  RewardModel(
    id: 'streak_7',
    title: 'Weekly Champion',
    description: 'Hold a solid 7-day perfect habit streak.',
    rewardType: 'streak',
    unlockCondition: 'streak_7',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  RewardModel(
    id: 'water_goal_3',
    title: 'H2O Master',
    description: 'Meet your daily water target 3 days in a row.',
    rewardType: 'badge',
    unlockCondition: 'water_streak_3',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
  RewardModel(
    id: 'focus_100m',
    title: 'Laser Focus',
    description: 'Accumulate 100 total minutes of deep work.',
    rewardType: 'badge',
    unlockCondition: 'focus_mins_100',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];
