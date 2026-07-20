import 'dart:io';

import 'package:fitquest_rpg/core/time/app_clock.dart';
import 'package:fitquest_rpg/data/datasources/hive_datasource.dart';
import 'package:fitquest_rpg/data/models/boss_battle_model.dart';
import 'package:fitquest_rpg/data/models/skill_model.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/data/models/workout_plan_model.dart';
import 'package:fitquest_rpg/domain/services/workout_completion_service.dart';
import 'package:fitquest_rpg/providers/achievement_provider.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/quest_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:fitquest_rpg/providers/weekly_plan_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory temporaryDirectory;
  final now = DateTime(2026, 7, 20, 18); // Monday / Push Day

  setUpAll(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('fitquest_completion_');
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
    await Hive.box(HiveDatasource.gameStateBoxName)
        .put('_dataVersion', HiveDatasource.currentDataVersion);
  });

  tearDownAll(() async {
    await Hive.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('one atomic session updates workout, user, quests, and milestone',
      () async {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(FixedAppClock(now)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(userProvider.future);
    await container.read(userProvider.notifier).createCharacter(
          name: 'Tester',
          fitnessLevel: 'Intermediate',
        );
    final plan = await container.read(weeklyPlanProvider.future);
    final questsBefore = container.read(questProvider);
    expect(questsBefore, hasLength(3));

    final workout = _completedDay(plan, now, eventId: 'workout:atomic');
    final result = await container
        .read(workoutCompletionServiceProvider)
        .complete(workout);

    expect(result.xpAwarded, 23);
    expect(result.workout.isCommitted, isTrue);
    expect(result.workout.validSetCount, 24);
    expect(
      result.achievementsUnlocked,
      contains('awakening'),
    );
    expect(container.read(questProvider).every((quest) => quest.isCompleted),
        isTrue);
    final user = container.read(userProvider).requireValue!;
    expect(user.totalXp, 28); // 23 session + daily quest cap of 5
    expect(user.totalWorkoutsCompleted, 1);
    expect(user.streak, 1);
    expect(user.masteryXp.keys, containsAll(['push_up', 'shoulder_raise']));
    expect(user.unlockedTitles, contains('Awakened'));
    expect(
      (await container.read(workoutRepositoryProvider).getWorkout(workout.id))!
          .isCommitted,
      isTrue,
    );

    final replay = await container
        .read(workoutCompletionServiceProvider)
        .complete(workout);
    expect(replay.xpAwarded, 23);
    final replayedUser = container.read(userProvider).requireValue!;
    expect(replayedUser.totalXp, 28);
    expect(replayedUser.totalWorkoutsCompleted, 1);
    expect(
      container.read(questProvider).every(
            (quest) => quest.appliedEventIds.length == 1,
          ),
      isTrue,
    );
  });

  test('startup recovery commits a valid pending workout once', () async {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(FixedAppClock(now)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(userProvider.future);
    await container
        .read(userProvider.notifier)
        .createCharacter(name: 'Tester', fitnessLevel: 'Intermediate');
    final plan = await container.read(weeklyPlanProvider.future);
    container.read(questProvider);
    container.read(achievementProvider);
    final pending = _completedDay(
      plan,
      now,
      eventId: 'workout:pending',
    );
    await container.read(workoutRepositoryProvider).saveWorkout(pending);

    final recovered =
        await container.read(workoutCompletionServiceProvider).recoverPending();
    final user = container.read(userProvider).requireValue!;

    expect(recovered, 1);
    expect(user.totalWorkoutsCompleted, 1);
    expect(
      (await container.read(workoutRepositoryProvider).getWorkout(pending.id))!
          .isCommitted,
      isTrue,
    );
  });

  test('completion derives the rate and rejects a forged value', () async {
    final container = ProviderContainer(
      overrides: [
        clockProvider.overrideWithValue(FixedAppClock(now)),
      ],
    );
    addTearDown(container.dispose);
    await container.read(userProvider.future);
    await container
        .read(userProvider.notifier)
        .createCharacter(name: 'Tester', fitnessLevel: 'Intermediate');
    final plan = await container.read(weeklyPlanProvider.future);
    final forged = _completedDay(
      plan,
      now,
      eventId: 'workout:forged',
      validSetLimit: 1,
    ).copyWith(completionRate: 1);

    expect(
      () => container.read(workoutCompletionServiceProvider).complete(forged),
      throwsStateError,
    );
    expect(
      await container.read(workoutRepositoryProvider).getWorkout(forged.id),
      isNull,
    );
  });
}

WorkoutModel _completedDay(
  WorkoutPlanModel plan,
  DateTime now, {
  required String eventId,
  int validSetLimit = 100000,
}) {
  final day = plan.dayFor(now);
  var setCounter = 0;
  return WorkoutModel(
    id: eventId,
    eventId: eventId,
    date: now,
    createdAt: now,
    planId: plan.id,
    plannedDayId: day.id,
    processingStateIndex: WorkoutProcessingState.pending.index,
    completionRate: 1,
    scheduled: true,
    countsForStreak: true,
    exercises: [
      for (var exerciseIndex = 0;
          exerciseIndex < day.exercises.length;
          exerciseIndex++)
        ExerciseRecord(
          id: 'exercise-$exerciseIndex',
          exerciseTypeIndex: day.exercises[exerciseIndex].exerciseTypeIndex,
          movementId: day.exercises[exerciseIndex].movementId,
          displayName: day.exercises[exerciseIndex].name,
          trackingMetricIndex: day.exercises[exerciseIndex].trackingMetricIndex,
          orderIndex: exerciseIndex,
          variations: [
            for (final variation in day.exercises[exerciseIndex].variations)
              VariationRecord(
                id: variation.id,
                name: variation.name,
                difficultyMultiplier: variation.difficultyMultiplier,
                sets: [
                  for (var setIndex = 0;
                      setIndex < variation.targetSets;
                      setIndex++)
                    WorkoutSetRecord(
                      id: '${variation.id}-$setIndex',
                      reps: variation.targetValue,
                      loadKg: variation.targetLoadKg,
                      rpe: 7,
                      completed: setCounter++ < validSetLimit,
                    ),
                ],
              ),
          ],
        ),
    ],
  );
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
  if (!Hive.isAdapterRegistered(VariationRecordAdapter().typeId)) {
    Hive.registerAdapter<VariationRecord>(VariationRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(WorkoutSetRecordAdapter().typeId)) {
    Hive.registerAdapter<WorkoutSetRecord>(WorkoutSetRecordAdapter());
  }
  if (!Hive.isAdapterRegistered(WorkoutPlanModelAdapter().typeId)) {
    Hive.registerAdapter<WorkoutPlanModel>(WorkoutPlanModelAdapter());
  }
  if (!Hive.isAdapterRegistered(PlannedDayModelAdapter().typeId)) {
    Hive.registerAdapter<PlannedDayModel>(PlannedDayModelAdapter());
  }
  if (!Hive.isAdapterRegistered(PlannedExerciseModelAdapter().typeId)) {
    Hive.registerAdapter<PlannedExerciseModel>(
      PlannedExerciseModelAdapter(),
    );
  }
  if (!Hive.isAdapterRegistered(VariationPlanModelAdapter().typeId)) {
    Hive.registerAdapter<VariationPlanModel>(VariationPlanModelAdapter());
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
