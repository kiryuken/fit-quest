import 'package:uuid/uuid.dart';
import '../../../core/enums/stat_type.dart';
import '../../../core/time/app_clock.dart';
import '../../../domain/services/hp_calculator.dart';
import '../../../domain/services/stat_growth_service.dart';
import '../../datasources/hive_datasource.dart';
import '../../models/user_model.dart';
import '../repository_exception.dart';
import '../interfaces/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final HiveDatasource _datasource;
  final AppClock _clock;
  final Uuid _uuid;

  UserRepositoryImpl(
    this._datasource, {
    AppClock clock = const SystemAppClock(),
    Uuid uuid = const Uuid(),
  })  : _clock = clock,
        _uuid = uuid;

  static const _userKey = 'current_user';

  @override
  Future<UserModel?> getUser() async {
    return _datasource.safeGetUser(_userKey);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      await _datasource.userBox.put(_userKey, user);
    } catch (error) {
      throw RepositoryException('save user', error);
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      await _datasource.userBox.delete(_userKey);
    } catch (error) {
      throw RepositoryException('delete user', error);
    }
  }

  @override
  Future<UserModel> createDefaultUser({
    required String name,
    int age = 18,
    double height = 170.0,
    double weight = 70.0,
    String fitnessLevel = 'Beginner',
    StatType? preferredFocus,
  }) async {
    final now = _clock.now();
    final defaultStats = StatGrowthService.indexedStatsAtLevel(1);
    final maxHp = HpCalculator.maxHp(
      defaultStats[StatType.vitality.index]!.round(),
      1,
    );

    final user = UserModel(
      id: _uuid.v4(),
      name: name,
      stats: defaultStats,
      currentHp: maxHp,
      maxHp: maxHp,
      createdAt: now,
      updatedAt: now,
      age: age,
      height: height,
      weight: weight,
      fitnessLevel: fitnessLevel,
      preferredFocusIndex: preferredFocus?.index,
      xpBudgetDate: now,
    );

    await saveUser(user);
    return user;
  }
}
