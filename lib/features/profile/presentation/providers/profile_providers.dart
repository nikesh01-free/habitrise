import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/profile_model.dart';
import '../../data/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

class ProfileNotifier extends AutoDisposeNotifier<ProfileModel?> {
  @override
  ProfileModel? build() {
    final repo = ref.read(profileRepositoryProvider);
    return repo.getProfile();
  }

  Future<void> updateProfile({
    required String displayName,
    required String userType,
    required int stepGoal,
    required int waterGoal,
  }) async {
    // Basic Validations
    if (displayName.trim().length < 2 || displayName.trim().length > 30) {
      throw Exception('Name must be 2–30 characters.');
    }
    if (stepGoal < 500 || stepGoal > 100000) {
      throw Exception('Step goal must be between 500 and 100000.');
    }
    if (waterGoal < 500 || waterGoal > 15000) {
      throw Exception('Water goal must be between 500ml and 15000ml.');
    }

    final current = state;
    final now = DateTime.now();

    final updated = ProfileModel(
      id: current?.id ?? const Uuid().v4(),
      displayName: displayName.trim(),
      ageGroup: 'unspecified', // placeholder for V1
      userType: userType,
      dailyStepGoal: stepGoal,
      dailyWaterGoalMl: waterGoal,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );

    final repo = ref.read(profileRepositoryProvider);
    await repo.saveProfile(updated);
    state = updated;
  }
}

final profileProvider =
    AutoDisposeNotifierProvider<ProfileNotifier, ProfileModel?>(() {
      return ProfileNotifier();
    });
