import 'package:hive/hive.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/reward_model.dart';

class RewardsRepository {
  final Box _box = Hive.box(LocalBoxNames.rewards);

  List<RewardModel> getAllRewards() {
    return _box.values
        .whereType<Map>()
        .map((e) => RewardModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> unlockReward(String rewardId) async {
    final raw = _box.get(rewardId);
    if (raw != null) {
      final reward = RewardModel.fromMap(Map<String, dynamic>.from(raw));
      if (!reward.isUnlocked) {
        final now = DateTime.now();
        final updated = reward.copyWith(
          isUnlocked: true,
          unlockedAt: now,
          updatedAt: now,
        );
        await _box.put(rewardId, updated.toMap());
      }
    }
  }

  /// Populates defaults if none exist (useful during bootstrap)
  Future<void> initDefaultRewards(List<RewardModel> defaults) async {
    if (_box.isEmpty) {
      for (final r in defaults) {
        await _box.put(r.id, r.toMap());
      }
    }
  }
}
