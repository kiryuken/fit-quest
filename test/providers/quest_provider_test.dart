import 'dart:io';

import 'package:fitquest_rpg/core/enums/exercise_tracking_metric.dart';
import 'package:fitquest_rpg/core/enums/exercise_type.dart';
import 'package:fitquest_rpg/data/datasources/hive_datasource.dart';
import 'package:fitquest_rpg/data/models/daily_quest_model.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/domain/services/user_progression_service.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/quest_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory temporaryDirectory;

  setUpAll(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('fitquest_quest_provider_');
    Hive.init(temporaryDirectory.path);
    await Hive.openBox(HiveDatasource.gameStateBoxName);
  });

  setUp(() async {
    await Hive.box(HiveDatasource.gameStateBoxName).clear();
  });

  tearDownAll(() async {
    await Hive.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('quest completion grants its small XP reward exactly once', () async {
    final rewards = <({String id, int amount})>[];
    final quest = DailyQuestModel(
      id: 'push_up_test',
      title: 'Push Ups',
      metricSlug: 'push_up',
      target: 10,
      progress: 8,
      expReward: 2,
      date: DateTime(2026, 7, 20),
    );
    final notifier = QuestNotifier.forTesting(
      initialQuests: [quest],
      onExpReward: (id, amount) async {
        rewards.add((id: id, amount: amount));
      },
    );

    await notifier.addProgress(quest.id, 2, eventId: 'workout:one');
    await notifier.addProgress(quest.id, 5, eventId: 'workout:two');

    expect(notifier.state.single.isCompleted, isTrue);
    expect(notifier.state.single.progress, 10);
    expect(rewards, [(id: quest.id, amount: 2)]);
  });

  test('running quest reads meters from distance sets, never reps', () async {
    final quest = DailyQuestModel(
      id: 'running_test',
      title: 'Run 3000 meters',
      metricSlug: 'running',
      target: 3000,
      expReward: 2,
      date: DateTime(2026, 7, 20),
    );
    final notifier = QuestNotifier.forTesting(
      initialQuests: [quest],
      onExpReward: (_, __) async {},
    );
    final workout = _distanceWorkout(
      reps: 9999,
      distanceMeters: 3000,
      eventId: 'workout:run',
    );

    await notifier.applyWorkout(workout);

    expect(notifier.state.single.progress, 3000);
    expect(notifier.state.single.isCompleted, isTrue);
  });

  test('one workout event cannot be applied to the same quest twice', () async {
    final quest = DailyQuestModel(
      id: 'running_test',
      title: 'Run 6000 meters',
      metricSlug: 'running',
      target: 6000,
      expReward: 2,
      date: DateTime(2026, 7, 20),
    );
    final notifier = QuestNotifier.forTesting(
      initialQuests: [quest],
      onExpReward: (_, __) async {},
    );
    final workout = _distanceWorkout(
      distanceMeters: 3000,
      eventId: 'workout:same',
    );

    await notifier.applyWorkout(workout);
    await notifier.applyWorkout(workout);

    expect(notifier.state.single.progress, 3000);
    expect(notifier.state.single.appliedEventIds, ['workout:same']);
  });

  test('a recovered workout from another date cannot mutate today quests',
      () async {
    final quest = DailyQuestModel(
      id: 'running_today',
      title: 'Run today',
      metricSlug: 'running',
      target: 3000,
      expReward: 2,
      date: DateTime(2026, 7, 20),
    );
    final notifier = QuestNotifier.forTesting(
      initialQuests: [quest],
      onExpReward: (_, __) async {},
    );
    final oldWorkout = _distanceWorkout(
      distanceMeters: 3000,
      eventId: 'workout:yesterday',
      date: DateTime(2026, 7, 19),
    );

    await notifier.applyWorkout(oldWorkout);

    expect(notifier.state.single.progress, 0);
    expect(notifier.state.single.appliedEventIds, isEmpty);
  });

  test('quest reward resolves the current user notifier after invalidation',
      () async {
    final rewards = <({int generation, int amount})>[];
    final lifecycle = _UserLifecycle();
    final container = ProviderContainer(
      overrides: [
        hiveDatasourceProvider.overrideWithValue(HiveDatasource()),
        userProvider.overrideWith(
          () => _TrackingUserNotifier(
            lifecycle: lifecycle,
            rewards: rewards,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    await container.read(userProvider.future);
    expect(lifecycle.generation, 1);

    final quest = container.read(questProvider).first;
    container.invalidate(userProvider);

    await container
        .read(questProvider.notifier)
        .addProgress(quest.id, quest.target);

    expect(lifecycle.generation, 2);
    expect(rewards, [(generation: 2, amount: quest.expReward)]);
  });
}

WorkoutModel _distanceWorkout({
  int reps = 0,
  required double distanceMeters,
  required String eventId,
  DateTime? date,
}) {
  final now = date ?? DateTime(2026, 7, 20);
  return WorkoutModel(
    id: eventId,
    eventId: eventId,
    date: now,
    createdAt: now,
    completed: true,
    processingStateIndex: WorkoutProcessingState.committed.index,
    completionRate: 1,
    exercises: [
      ExerciseRecord(
        id: 'running-record',
        exerciseTypeIndex: ExerciseType.running.index,
        movementId: 'running',
        displayName: 'Running',
        trackingMetricIndex: ExerciseTrackingMetric.distanceMeters.index,
        variations: [
          VariationRecord(
            id: 'easy-run',
            name: 'Easy Run',
            sets: [
              WorkoutSetRecord(
                id: 'run-set',
                reps: reps,
                distanceMeters: distanceMeters,
                durationSeconds: 1200,
                completed: true,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _UserLifecycle {
  int generation = 0;
}

class _TrackingUserNotifier extends UserNotifier {
  final _UserLifecycle lifecycle;
  final List<({int generation, int amount})> rewards;

  _TrackingUserNotifier({
    required this.lifecycle,
    required this.rewards,
  });

  @override
  Future<UserModel?> build() async {
    lifecycle.generation++;
    return _user();
  }

  @override
  Future<ProgressionResult> awardQuestXp({
    required int amount,
    required String questId,
  }) async {
    rewards.add((generation: lifecycle.generation, amount: amount));
    return ProgressionResult(
      user: _user(),
      xpAwarded: amount,
      leveledUp: false,
    );
  }
}

UserModel _user() {
  final now = DateTime(2026, 7, 20);
  return UserModel(
    id: 'user',
    name: 'Tester',
    createdAt: now,
    updatedAt: now,
  );
}
