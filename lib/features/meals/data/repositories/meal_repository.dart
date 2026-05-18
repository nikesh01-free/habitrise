import 'package:hive/hive.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/meal_log_model.dart';

class MealRepository {
  final Box _box = Hive.box(LocalBoxNames.mealLogs);

  List<MealLogModel> getMealsByDate(String dateStr) {
    final List<MealLogModel> items = [];
    for (final val in _box.values) {
      try {
        if (val is Map) {
          final m = MealLogModel.fromMap(Map<String, dynamic>.from(val));
          if (m.logDate == dateStr) items.add(m);
        }
      } catch (_) {}
    }
    return items;
  }

  Future<void> saveMeal(MealLogModel meal) async {
    await _box.put(meal.id, meal.toMap());
  }

  Future<void> deleteMeal(String id) async {
    await _box.delete(id);
  }

  List<MealLogModel> getAllMeals() {
    final List<MealLogModel> items = [];
    for (final val in _box.values) {
      try {
        if (val is Map) {
          items.add(MealLogModel.fromMap(Map<String, dynamic>.from(val)));
        }
      } catch (_) {}
    }
    return items;
  }
}
