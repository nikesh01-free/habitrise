import 'package:hive/hive.dart';
import '../../../../core/storage/local_box_names.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final Box _box = Hive.box(LocalBoxNames.appProfile);
  static const String _profileKey = 'current_profile';

  ProfileModel? getProfile() {
    final data = _box.get(_profileKey);
    if (data == null || data is! Map) return null;

    try {
      final Map<String, dynamic> safeMap = Map<String, dynamic>.from(data);
      return ProfileModel.fromMap(safeMap);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveProfile(ProfileModel profile) async {
    await _box.put(_profileKey, profile.toMap());
  }

  Future<void> deleteProfile() async {
    await _box.delete(_profileKey);
  }
}
