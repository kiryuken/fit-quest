import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/enums/stat_type.dart';
import '../core/utils/level_requirements.dart';
import '../data/models/user_model.dart';
import '../domain/services/user_progression_service.dart';
import 'initialization_provider.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserModel?>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return ref.read(userRepositoryProvider).getUser();
  }

  Future<UserModel> createCharacter({
    required String name,
    int age = 18,
    double height = 170,
    double weight = 70,
    String fitnessLevel = 'Beginner',
    StatType? preferredFocus,
  }) async {
    final sanitizedName = name.trim().isEmpty
        ? 'Warrior'
        : name.trim().substring(
              0,
              name.trim().length.clamp(0, 40),
            );
    final user = await ref.read(userRepositoryProvider).createDefaultUser(
          name: sanitizedName,
          age: age.clamp(10, 120),
          height: height.clamp(100, 250),
          weight: weight.clamp(30, 300),
          fitnessLevel: fitnessLevel,
          preferredFocus: preferredFocus,
        );
    state = AsyncData(user);
    return user;
  }

  Future<ProgressionResult> awardQuestXp({
    required int amount,
    required String questId,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Create a character before earning quest XP.');
    }
    final result = UserProgressionService.awardXp(
      current,
      amount,
      source: XpAwardSource.quest,
      now: ref.read(clockProvider).now(),
      eventId: 'quest:$questId',
    );
    await _persist(result.user);
    return result;
  }

  Future<void> gainXp(int amount) async {
    final current = state.valueOrNull;
    if (current == null) return;
    final updated = UserProgressionService.gainXp(
      current,
      amount,
      now: ref.read(clockProvider).now(),
    );
    await _persist(updated);
  }

  Future<bool> unlockSkill(String skillId) async {
    final current = state.valueOrNull;
    if (current == null) return false;
    if (current.hasSkill(skillId)) return true;

    final updated = current.copyWith(
      unlockedSkills: [...current.unlockedSkills, skillId],
      skillLevels: {...current.skillLevels, skillId: 1},
      updatedAt: ref.read(clockProvider).now(),
    );
    await _persist(updated);
    return true;
  }

  Future<bool> levelUpSkill(String skillId) async {
    final current = state.valueOrNull;
    if (current == null || !current.hasSkill(skillId)) return false;

    final updated = current.copyWith(
      skillLevels: {
        ...current.skillLevels,
        skillId: current.skillLevel(skillId) + 1,
      },
      updatedAt: ref.read(clockProvider).now(),
    );
    await _persist(updated);
    return true;
  }

  Future<ProgressionResult> completeWorkout({
    required String eventId,
    required int requestedXp,
    required Map<String, int> masteryPoints,
    required Iterable<String> personalRecordMovementIds,
    required bool countsForStreak,
    required int missedScheduledDays,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Create a character before completing a workout.');
    }
    final result = UserProgressionService.completeWorkout(
      current,
      eventId: eventId,
      requestedXp: requestedXp,
      masteryPoints: masteryPoints,
      personalRecordMovementIds: personalRecordMovementIds,
      now: ref.read(clockProvider).now(),
      countsForStreak: countsForStreak,
      missedScheduledDays: missedScheduledDays,
    );
    await _persist(result.user);
    return result;
  }

  Future<ProgressionResult> completeBossVictory({
    required String bossId,
    required int xpReward,
  }) async {
    final current = state.valueOrNull;
    if (current == null) {
      throw StateError('Create a character before fighting a boss.');
    }
    final result = UserProgressionService.completeBossVictory(
      current,
      bossId: bossId,
      requestedXp: xpReward,
      now: ref.read(clockProvider).now(),
    );
    await _persist(result.user);
    return result;
  }

  Future<void> unlockTitles(Iterable<String> titles) async {
    final current = state.valueOrNull;
    if (current == null || titles.isEmpty) return;
    final updated = UserProgressionService.unlockTitles(
      current,
      titles,
      now: ref.read(clockProvider).now(),
    );
    await _persist(updated);
  }

  Future<void> _persist(UserModel user) async {
    await ref.read(userRepositoryProvider).saveUser(user);
    state = AsyncData(user);
  }
}

final userLevelProvider = Provider<int>((ref) {
  return ref.watch(userProvider).valueOrNull?.level ?? 1;
});

final userStatsProvider = Provider<Map<StatType, double>>((ref) {
  final user = ref.watch(userProvider).valueOrNull;
  if (user == null) return {};
  return {
    for (final stat in StatType.values) stat: user.getStatValue(stat),
  };
});

final userStreakProvider = Provider<int>((ref) {
  return ref.watch(userProvider).valueOrNull?.streak ?? 0;
});

final userShieldsProvider = Provider<int>((ref) {
  return ref.watch(userProvider).valueOrNull?.streakShields ?? 0;
});

final levelProgressProvider = Provider<double>((ref) {
  final user = ref.watch(userProvider).valueOrNull;
  if (user == null) return 0;
  return LevelRequirements.levelProgress(user.level, user.currentXp);
});
