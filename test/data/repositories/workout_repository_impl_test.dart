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
}

WorkoutModel _workout({
  required String id,
  List<ExerciseRecord> exercises = const [],
}) {
  final now = DateTime.now();
  return WorkoutModel(
    id: id,
    date: now,
    exercises: exercises,
    completed: true,
    createdAt: now,
  );
}
