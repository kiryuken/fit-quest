import 'dart:io';

import 'package:fitquest_rpg/core/enums/exercise_type.dart';
import 'package:fitquest_rpg/data/datasources/hive_datasource.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/data/repositories/implementations/workout_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

void main() {
  late Directory temporaryDirectory;
  late Box<WorkoutModel> workoutsBox;
  late WorkoutRepositoryImpl repository;

  setUpAll(() async {
    temporaryDirectory =
        await Directory.systemTemp.createTemp('fitquest_workout_repository_');
    Hive.init(temporaryDirectory.path);
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(WorkoutModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ExerciseRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(VariationRecordAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(WorkoutSetRecordAdapter());
    }
    workoutsBox =
        await Hive.openBox<WorkoutModel>(HiveDatasource.workoutsBoxName);
    repository = WorkoutRepositoryImpl(HiveDatasource());
  });

  setUp(() => workoutsBox.clear());

  tearDownAll(() async {
    await Hive.close();
    await temporaryDirectory.delete(recursive: true);
  });

  test('returns null instead of throwing when an ID is missing', () async {
    expect(await repository.getWorkout('missing-id'), isNull);
  });

  test('returns a workout stored under its ID', () async {
    final workout = _workout(id: 'known-id');
    await workoutsBox.put(workout.id, workout);

    expect(await repository.getWorkout(workout.id), same(workout));
  });

  test('aggregates distance-based exercise totals in meters', () async {
    final workout = _workout(
      id: 'running-id',
      exercises: [
        ExerciseRecord(
          id: 'running-record',
          exerciseTypeIndex: ExerciseType.running.index,
          reps: 0,
          distanceMeters: 3000,
        ),
      ],
    );
    await workoutsBox.put(workout.id, workout);

    expect(
      await repository.getTotalExerciseCount(ExerciseType.running.index),
      3000,
    );
  });

  test('paginates committed history newest first', () async {
    for (var index = 0; index < 25; index++) {
      final workout = _workout(
        id: 'workout-$index',
        date: DateTime(2026, 7, 1).add(Duration(hours: index)),
      );
      await workoutsBox.put(workout.id, workout);
    }

    final first = await repository.getWorkouts(limit: 20);
    final second = await repository.getWorkouts(
      beforeDate: first.last.date,
      limit: 20,
    );

    expect(first, hasLength(20));
    expect(second, hasLength(5));
    expect(first.first.id, 'workout-24');
    expect(second.last.id, 'workout-0');
  });

  test('pagination cursor does not lose sessions sharing a timestamp',
      () async {
    final sameTime = DateTime(2026, 7, 20, 18);
    for (final id in ['a', 'b', 'c']) {
      await repository.saveWorkout(_workout(id: id, date: sameTime));
    }

    final first = await repository.getWorkouts(limit: 2);
    final second = await repository.getWorkouts(
      beforeDate: first.last.date,
      beforeId: first.last.id,
      limit: 2,
    );

    expect(first.map((workout) => workout.id), ['c', 'b']);
    expect(second.map((workout) => workout.id), ['a']);
  });

  test('pending records are recoverable but hidden from normal history',
      () async {
    final pending = _workout(
      id: 'pending',
      processingState: WorkoutProcessingState.pending,
    );
    await repository.saveWorkout(pending);

    expect(await repository.getAllWorkouts(), isEmpty);
    expect(await repository.getPendingWorkouts(), [pending]);
  });
}

WorkoutModel _workout({
  required String id,
  DateTime? date,
  List<ExerciseRecord> exercises = const [],
  WorkoutProcessingState processingState = WorkoutProcessingState.committed,
}) {
  final now = date ?? DateTime.now();
  return WorkoutModel(
    id: id,
    date: now,
    exercises: exercises,
    completed: true,
    processingStateIndex: processingState.index,
    completionRate: 1,
    createdAt: now,
  );
}
