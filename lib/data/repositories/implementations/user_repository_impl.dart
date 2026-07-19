import 'package:uuid/uuid.dart';
import '../../datasources/hive_datasource.dart';
import '../../models/user_model.dart';
import '../interfaces/user_repository.dart';
import '../../../core/enums/stat_type.dart';

class UserRepositoryImpl implements UserRepository {
  final HiveDatasource _datasource;
  UserRepositoryImpl(this._datasource);

  static const _userKey = 'current_user';

  @override
  Future<UserModel?> getUser() async {
    return _datasource.safeGetUser(_userKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await _datasource.userBox.put(_userKey, user);
  }

  @override
  Future<void> deleteUser() async {
    await _datasource.userBox.delete(_userKey);
  }

  @override
  Future<UserModel> createDefaultUser({
    required String name,
    int age = 18,
    double height = 170.0,
    double weight = 70.0,
  }) async {
    final now = DateTime.now();
    final defaultStats = <int, int>{};
    for (final stat in StatType.values) {
      defaultStats[stat.index] = 1;
    }

    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      stats: defaultStats,
      currentHp: 100,
      maxHp: 100,
      lastWorkoutAt: now,
      createdAt: now,
      updatedAt: now,
      age: age,
      height: height,
      weight: weight,
    );

    await saveUser(user);
    return user;
  }
}
