import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/meal_log_model.dart';
import '../../data/repositories/meal_repository.dart';

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepository();
});

class TodayMealsNotifier extends AutoDisposeNotifier<List<MealLogModel>> {
  @override
  List<MealLogModel> build() {
    return _fetchToday();
  }

  List<MealLogModel> _fetchToday() {
    final repo = ref.read(mealRepositoryProvider);
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    return repo.getMealsByDate(dateStr);
  }

  Future<void> logMeal({
    required String name,
    required String type,
    required String status,
    String? plannedTime,
  }) async {
    if (name.trim().length < 2 || name.trim().length > 40) {
      throw Exception('Meal name must be 2–40 characters.');
    }

    final current = _fetchToday();
    if (current.any(
      (m) => m.mealName.toLowerCase() == name.trim().toLowerCase(),
    )) {
      throw Exception('This meal already exists today.');
    }

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final meal = MealLogModel(
      id: const Uuid().v4(),
      logDate: dateStr,
      mealName: name.trim(),
      mealType: type,
      status: status,
      plannedTime: plannedTime,
      completedTime: status == 'completed' ? now : null,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(mealRepositoryProvider).saveMeal(meal);
    state = _fetchToday();
  }

  Future<void> updateStatus(String id, String newStatus) async {
    final currentList = _fetchToday();
    final idx = currentList.indexWhere((element) => element.id == id);
    if (idx == -1) return;

    final original = currentList[idx];
    final updated = original.copyWith(
      status: newStatus,
      completedTime: newStatus == 'completed' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    await ref.read(mealRepositoryProvider).saveMeal(updated);
    state = _fetchToday();
  }

  Future<void> updateMealDetails({
    required String id,
    required String name,
    required String type,
    required String status,
  }) async {
    if (name.trim().length < 2 || name.trim().length > 40) {
      throw Exception('Meal name must be 2–40 characters.');
    }

    final currentList = _fetchToday();
    final idx = currentList.indexWhere((element) => element.id == id);
    if (idx == -1) return;

    // Check duplicates excluding current item
    if (currentList.any(
      (m) =>
          m.id != id && m.mealName.toLowerCase() == name.trim().toLowerCase(),
    )) {
      throw Exception('This meal already exists today.');
    }

    final original = currentList[idx];
    final updated = original.copyWith(
      mealName: name.trim(),
      mealType: type,
      status: status,
      completedTime: status == 'completed' ? DateTime.now() : null,
      updatedAt: DateTime.now(),
    );

    await ref.read(mealRepositoryProvider).saveMeal(updated);
    state = _fetchToday();
  }

  Future<void> deleteMeal(String id) async {
    await ref.read(mealRepositoryProvider).deleteMeal(id);
    state = _fetchToday();
  }
}

final todayMealsProvider =
    AutoDisposeNotifierProvider<TodayMealsNotifier, List<MealLogModel>>(() {
      return TodayMealsNotifier();
    });
