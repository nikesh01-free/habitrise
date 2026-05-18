import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/focus_session_model.dart';

class FocusRepository {
  final Box _box = Hive.box(LocalBoxNames.focusSessions);
  final _uuid = const Uuid();

  Future<FocusSessionModel> startSession({
    required String category,
    required int plannedMinutes,
  }) async {
    final now = DateTime.now();
    final session = FocusSessionModel(
      id: _uuid.v4(),
      category: category,
      plannedMinutes: plannedMinutes,
      completedMinutes: 0,
      status: 'partial', // In progress initially
      startedAt: now,
      createdAt: now,
      updatedAt: now,
    );

    await _box.put(session.id, session.toMap());
    return session;
  }

  Future<void> finishSession({
    required String id,
    required int completedMinutes,
    required String status,
  }) async {
    final raw = _box.get(id);
    if (raw != null && raw is Map) {
      try {
        final current = FocusSessionModel.fromMap(
          Map<String, dynamic>.from(raw),
        );
        final now = DateTime.now();
        final updated = current.copyWith(
          completedMinutes: completedMinutes,
          status: status,
          endedAt: now,
          updatedAt: now,
        );
        await _box.put(id, updated.toMap());
      } catch (_) {}
    }
  }

  List<FocusSessionModel> getHistory() {
    final List<FocusSessionModel> list = [];
    for (final val in _box.values) {
      try {
        if (val is Map) {
          list.add(FocusSessionModel.fromMap(Map<String, dynamic>.from(val)));
        }
      } catch (_) {}
    }
    return list;
  }

  Future<void> deleteSession(String id) async {
    await _box.delete(id);
  }
}
