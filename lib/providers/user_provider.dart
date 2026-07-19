import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../core/enums/stat_type.dart';
import '../core/utils/level_requirements.dart';
import '../domain/services/user_progression_service.dart';
import 'initialization_provider.dart';

/// Current user state — null means no character created yet.
/// Use `?? UserModel.empty()` for safe defaults in UI.
final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    final repo = ref.read(userRepositoryProvider);
    final ds = ref.read(hiveDatasourceProvider);
    await ds.checkAndMigrate();
    final user = await repo.getUser();
    return user; // null = no character yet, navigate to onboarding
  }

  Future<UserModel> createCharacter({
    required String name,
    int age = 18,
    double height = 170.0,
    double weight = 70.0,
    String fitnessLevel = 'Beginner',
  }) async {
    final repo = ref.read(userRepositoryProvider);
    final user = await repo.createDefaultUser(
      name: name,
      age: age,
      height: height,
      weight: weight,
    );

    // Apply fitness level to initial stats
    final factor = fitnessLevel == 'Advanced'
        ? 5
        : (fitnessLevel == 'Intermediate' ? 3 : 1);
    final boostedStats = <int, int>{};
    for (final stat in StatType.values) {
      boostedStats[stat.index] = factor;
    }

    final updated = user.copyWith(stats: boostedStats);
    try {
      await repo.saveUser(updated);
      state = AsyncData(updated);
    } catch (e) {
      debugPrint('[UserNotifier] Failed to save character: $e');
      state = AsyncData(updated); // Still show boosted stats in UI
    }
    return updated;
  }

  Future<void> gainXp(int amount) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = UserProgressionService.gainXp(
      current,
      amount,
      now: DateTime.now(),
    );

    final repo = ref.read(userRepositoryProvider);
    try {
      await repo.saveUser(updated);
      state = AsyncData(updated);
    } catch (e) {
      debugPrint('[UserNotifier] Failed to save user: $e');
    }
  }

  Future<void> gainStatXp(Map<StatType, int> statXp) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = UserProgressionService.gainStatXp(
      current,
      statXp,
      now: DateTime.now(),
    );

    final repo = ref.read(userRepositoryProvider);
    try {
      await repo.saveUser(updated);
      state = AsyncData(updated);
    } catch (e) {
      debugPrint('[UserNotifier] Failed to save user: $e');
    }
  }

  Future<bool> unlockSkill(String skillId) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (current.hasSkill(skillId)) return true;

    final newSkills = [...current.unlockedSkills, skillId];
    final newLevels = Map<String, int>.from(current.skillLevels);
    newLevels[skillId] = 1;

    final updated = current.copyWith(
      unlockedSkills: newSkills,
      skillLevels: newLevels,
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(userRepositoryProvider);
    try {
      await repo.saveUser(updated);
      state = AsyncData(updated);
    } catch (e) {
      debugPrint('[UserNotifier] Failed to save user: $e');
    }
    return true;
  }

  Future<bool> levelUpSkill(String skillId) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (!current.hasSkill(skillId)) return false;

    final currentLevel = current.skillLevel(skillId);
    final newLevels = Map<String, int>.from(current.skillLevels);
    newLevels[skillId] = currentLevel + 1;

    final updated = current.copyWith(
      skillLevels: newLevels,
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(userRepositoryProvider);
    try {
      await repo.saveUser(updated);
      state = AsyncData(updated);
    } catch (e) {
      debugPrint('[UserNotifier] Failed to save user: $e');
    }
    return true;
  }

  Future<void> completeWorkout({
    required int xpGained,
    required Map<StatType, int> statGains,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = UserProgressionService.completeWorkout(
      current,
      xpGained: xpGained,
      statGains: statGains,
      now: DateTime.now(),
    );

    final repo = ref.read(userRepositoryProvider);
    try {
      await repo.saveUser(updated);
      state = AsyncData(updated);
    } catch (e) {
      debugPrint('[UserNotifier] Failed to save user: $e');
    }
  }

  Future<void> completeBossVictory({
    required int xpReward,
    required Map<StatType, int> statRewards,
  }) async {
    final current = state.valueOrNull;
    if (current == null) return;

    final updated = UserProgressionService.completeBossVictory(
      current,
      xpReward: xpReward,
      statRewards: statRewards,
      now: DateTime.now(),
    );

    final repo = ref.read(userRepositoryProvider);
    try {
      await repo.saveUser(updated);
      state = AsyncData(updated);
    } catch (e) {
      debugPrint('[UserNotifier] Failed to save boss victory: $e');
    }
  }
}

// Derived providers for convenient access
final userLevelProvider = Provider<int>((ref) {
  return ref.watch(userProvider).valueOrNull?.level ?? 1;
});

final userStatsProvider = Provider<Map<StatType, int>>((ref) {
  final user = ref.watch(userProvider).valueOrNull;
  if (user == null) return {};
  final result = <StatType, int>{};
  for (final stat in StatType.values) {
    result[stat] = user.stats[stat.index] ?? 1;
  }
  return result;
});

final userStreakProvider = Provider<int>((ref) {
  return ref.watch(userProvider).valueOrNull?.streak ?? 0;
});

final userShieldsProvider = Provider<int>((ref) {
  return ref.watch(userProvider).valueOrNull?.streakShields ?? 0;
});

final levelProgressProvider = Provider<double>((ref) {
  final user = ref.watch(userProvider).valueOrNull;
  if (user == null) return 0.0;
  return LevelRequirements.levelProgress(user.level, user.currentXp);
});
