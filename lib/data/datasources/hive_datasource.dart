import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
  static const int currentDataVersion = 1;

  Future<void> initialize() async {
    // No-op: Hive already initialized in main()
  }

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
    return u.copyWith(
      level: u.level.clamp(1, 9999),
      currentXp: u.currentXp.clamp(0, 999999),
      totalXp: u.totalXp.clamp(0, 999999),
      currentHp: u.currentHp.clamp(0, u.maxHp),
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
    final storedVersion = gameStateBox.get('_dataVersion', defaultValue: 0) as int;
    if (storedVersion < currentDataVersion) {
      debugPrint('[Hive] Data version $storedVersion < $currentDataVersion — clearing incompatible data');
      await userBox.clear();
      gameStateBox.put('_dataVersion', currentDataVersion);
    }
  }

  Box<UserModel> get userBox => Hive.box<UserModel>(userBoxName);
  Box<WorkoutModel> get workoutsBox => Hive.box<WorkoutModel>(workoutsBoxName);
  Box<SkillModel> get skillsBox => Hive.box<SkillModel>(skillsBoxName);
  Box<BossBattleModel> get bossesBox => Hive.box<BossBattleModel>(bossesBoxName);
  Box get gameStateBox => Hive.box(gameStateBoxName);
}
