import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/enums/stat_type.dart';
import '../../core/utils/level_requirements.dart';
import '../../domain/services/hp_calculator.dart';
import '../../domain/services/stat_growth_service.dart';
import '../models/user_model.dart';
import '../models/workout_model.dart';
import '../models/skill_model.dart';
import '../models/boss_battle_model.dart';

class HiveDatasource {
  static const String userBoxName = 'user';
  static const String workoutsBoxName = 'workouts';
  static const String skillsBoxName = 'skills';
  static const String bossesBoxName = 'bosses';
  static const String gameStateBoxName = 'game_state';

  /// Current data model version. Increment when UserModel fields change.
  static const int currentDataVersion = 2;
  static const String migrationNoticeKey = '_migration_notice_v2';

  Future<void> initialize() async {
    await checkAndMigrate();
  }

  bool get boxesAreOpen =>
      Hive.isBoxOpen(userBoxName) &&
      Hive.isBoxOpen(workoutsBoxName) &&
      Hive.isBoxOpen(gameStateBoxName);

  /// Get user with validation — guards against corrupt data.
  UserModel? safeGetUser(String key) {
    try {
      final user = userBox.get(key);
      if (user == null) return null;
      return _validateUser(user);
    } catch (e) {
      debugPrint('[HiveDatasource] Corrupt user data for $key: $e');
      userBox.delete(key);
      return null;
    }
  }

  UserModel _validateUser(UserModel u) {
    final totalXp = u.totalXp < 0 ? 0 : u.totalXp;
    final level = LevelRequirements.calculateLevel(totalXp);
    final stats = StatGrowthService.indexedStatsAtLevel(level);
    final maxHp = HpCalculator.maxHp(
      stats[StatType.vitality.index]!.round(),
      level,
    );
    return u.copyWith(
      level: level,
      currentXp: totalXp - LevelRequirements.totalXpForLevel(level),
      totalXp: totalXp,
      stats: stats,
      maxHp: maxHp,
      currentHp: u.currentHp.clamp(0, maxHp),
      streak: u.streak.clamp(0, 9999),
      streakShields: u.streakShields.clamp(0, 3),
      age: u.age.clamp(10, 120),
      height: u.height.clamp(100, 250),
      weight: u.weight.clamp(30, 300),
    );
  }

  /// Check if stored data version matches current.
  /// If not, clear corrupted/incompatible data.
  Future<void> checkAndMigrate() async {
    final storedVersion =
        gameStateBox.get('_dataVersion', defaultValue: 0) as int;
    if (storedVersion < currentDataVersion) {
      debugPrint(
        '[Hive] Data version $storedVersion < $currentDataVersion — '
        'resetting incompatible progression data',
      );
      await userBox.clear();
      await workoutsBox.clear();
      await skillsBox.clear();
      await bossesBox.clear();
      await gameStateBox.clear();
      await gameStateBox.put('_dataVersion', currentDataVersion);
      if (storedVersion > 0) {
        await gameStateBox.put(migrationNoticeKey, true);
      }
    }
  }

  Future<bool> consumeMigrationNotice() async {
    final pending =
        gameStateBox.get(migrationNoticeKey, defaultValue: false) as bool;
    if (pending) await gameStateBox.delete(migrationNoticeKey);
    return pending;
  }

  Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  Box<WorkoutModel> get workoutsBox => Hive.box<WorkoutModel>(workoutsBoxName);
  Box<SkillModel> get skillsBox => Hive.box<SkillModel>(skillsBoxName);
  Box<BossBattleModel> get bossesBox =>
      Hive.box<BossBattleModel>(bossesBoxName);
  Box get gameStateBox => Hive.box(gameStateBoxName);
}
