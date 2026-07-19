import 'dart:io';

import 'package:fitquest_rpg/data/datasources/hive_datasource.dart';
import 'package:fitquest_rpg/data/models/achievement_state.dart';
import 'package:fitquest_rpg/data/models/boss_battle_model.dart';
import 'package:fitquest_rpg/data/models/daily_quest_model.dart';
import 'package:fitquest_rpg/data/models/skill_model.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/providers/achievement_provider.dart';
import 'package:fitquest_rpg/providers/game_reset_provider.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/quest_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory temporaryDirectory;

  setUpAll(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('fitquest_game_reset_');
    Hive.init(temporaryDirectory.path);
    _registerAdapters();
    await Hive.openBox<UserModel>(HiveDatasource.userBoxName);
    await Hive.openBox<WorkoutModel>(HiveDatasource.workoutsBoxName);
    await Hive.openBox<SkillModel>(HiveDatasource.skillsBoxName);
    await Hive.openBox<BossBattleModel>(HiveDatasource.bossesBoxName);
    await Hive.openBox(HiveDatasource.gameStateBoxName);
  });

  setUp(() async {
    await Hive.box<UserModel>(HiveDatasource.userBoxName).clear();
    await Hive.box<WorkoutModel>(HiveDatasource.workoutsBoxName).clear();
    await Hive.box<SkillModel>(HiveDatasource.skillsBoxName).clear();
    await Hive.box<BossBattleModel>(HiveDatasource.bossesBoxName).clear();
    await Hive.box(HiveDatasource.gameStateBoxName).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('reset clears storage and rebuilds quest and achievement state',
      () async {
    final quests = QuestCatalog.today();
    quests[0] = quests[0].addProgress(1);
    final achievements = AchievementCatalog.defaults();
    achievements[0] = achievements[0].copyUnlocked();
    var questBuilds = 0;
    var achievementBuilds = 0;

    final container = ProviderContainer(
      overrides: [
        hiveDatasourceProvider.overrideWithValue(HiveDatasource()),
        questProvider.overrideWith((ref) {
          final initialQuests =
              questBuilds++ == 0 ? quests : QuestCatalog.today();
          return QuestNotifier.forTesting(
            initialQuests: initialQuests,
            onExpReward: (_) async {},
          );
        }),
        achievementProvider.overrideWith((ref) {
          final initialAchievements = achievementBuilds++ == 0
              ? achievements
              : AchievementCatalog.defaults();
          return AchievementNotifier.forTesting(
            initialAchievements: initialAchievements,
          );
        }),
      ],
    );
    addTearDown(container.dispose);

    await Hive.box(HiveDatasource.gameStateBoxName).put('stale', true);
    final oldQuestNotifier = container.read(questProvider.notifier);
    final oldAchievementNotifier = container.read(achievementProvider.notifier);
    expect(container.read(questProvider).first.progress, 1);
    expect(container.read(achievementProvider).first.unlocked, isTrue);

    await container.read(gameResetServiceProvider).resetAllData();

    expect(Hive.box(HiveDatasource.gameStateBoxName).isEmpty, isTrue);

    final newQuestNotifier = container.read(questProvider.notifier);
    final newAchievementNotifier = container.read(achievementProvider.notifier);
    expect(identical(newQuestNotifier, oldQuestNotifier), isFalse);
    expect(
      container.read(questProvider).every((quest) => quest.progress == 0),
      isTrue,
    );
    expect(
      container
          .read(achievementProvider)
          .every((achievement) => !achievement.unlocked),
      isTrue,
    );
    expect(
      identical(newAchievementNotifier, oldAchievementNotifier),
      isFalse,
    );
    expect(questBuilds, 2);
    expect(achievementBuilds, 2);
  });
}

void _registerAdapters() {
  if (!Hive.isAdapterRegistered(UserModelAdapter().typeId)) {
    Hive.registerAdapter<UserModel>(UserModelAdapter());
  }
  if (!Hive.isAdapterRegistered(WorkoutModelAdapter().typeId)) {
    Hive.registerAdapter<WorkoutModel>(WorkoutModelAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseRecordAdapter().typeId)) {
    Hive.registerAdapter<ExerciseRecord>(ExerciseRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(SkillModelAdapter().typeId)) {
    Hive.registerAdapter<SkillModel>(SkillModelAdapter());
  }
  if (!Hive.isAdapterRegistered(SkillLevelDataAdapter().typeId)) {
    Hive.registerAdapter<SkillLevelData>(SkillLevelDataAdapter());
  }
  if (!Hive.isAdapterRegistered(ExerciseRequirementAdapter().typeId)) {
    Hive.registerAdapter<ExerciseRequirement>(ExerciseRequirementAdapter());
  }
  if (!Hive.isAdapterRegistered(BossBattleModelAdapter().typeId)) {
    Hive.registerAdapter<BossBattleModel>(BossBattleModelAdapter());
  }
}
