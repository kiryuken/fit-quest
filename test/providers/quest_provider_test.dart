import 'dart:io';

import 'package:fitquest_rpg/core/data/exercise_definitions.dart';
import 'package:fitquest_rpg/core/enums/exercise_type.dart';
import 'package:fitquest_rpg/data/datasources/hive_datasource.dart';
import 'package:fitquest_rpg/data/models/daily_quest_model.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
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

  test('quest completion grants its XP reward exactly once', () async {
    final rewards = <int>[];
    final quest = DailyQuestModel(
      id: 'pushup_test',
      title: 'Push Ups',
      target: 10,
      progress: 8,
      expReward: 50,
      date: DateTime(2026, 7, 19),
    );
    final notifier = QuestNotifier.forTesting(
      initialQuests: [quest],
      onExpReward: (amount) async => rewards.add(amount),
    );

    await notifier.addProgress(quest.id, 2);
    await notifier.addProgress(quest.id, 5);

    expect(notifier.state.single.isCompleted, isTrue);
    expect(notifier.state.single.progress, 10);
    expect(rewards, [50]);
  });

  test('running distance completes a quest measured in meters', () async {
    final running = ExerciseDefinition.all.firstWhere(
      (exercise) => exercise.type == ExerciseType.running,
    );
    final quest = DailyQuestModel(
      id: 'running_test',
      title: 'Run (meters)',
      target: 3000,
      expReward: 45,
      date: DateTime(2026, 7, 19),
    );
    final notifier = QuestNotifier.forTesting(
      initialQuests: [quest],
      onExpReward: (_) async {},
    );

    await notifier.addProgress(
      quest.id,
      running.questProgressFor(3000),
    );

    expect(notifier.state.single.progress, 3000);
    expect(notifier.state.single.isCompleted, isTrue);
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
    return null;
  }

  @override
  Future<void> gainXp(int amount) async {
    rewards.add((generation: lifecycle.generation, amount: amount));
  }
}
