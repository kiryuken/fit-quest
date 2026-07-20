import '../../datasources/hive_datasource.dart';
import '../../models/workout_model.dart';
import '../interfaces/workout_repository.dart';
import '../repository_exception.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final HiveDatasource _datasource;

  WorkoutRepositoryImpl(this._datasource);

  @override
  Future<List<WorkoutModel>> getAllWorkouts({
    bool committedOnly = true,
  }) async {
    final workouts = _datasource.workoutsBox.values
        .where((workout) => !committedOnly || workout.isCommitted)
        .toList()
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        return byDate != 0 ? byDate : b.id.compareTo(a.id);
      });
    return workouts;
  }

  @override
  Future<List<WorkoutModel>> getWorkouts({
    DateTime? beforeDate,
    String? beforeId,
    int limit = 20,
    bool committedOnly = true,
  }) async {
    if (limit < 1 || limit > 100) {
      throw RangeError.range(limit, 1, 100, 'limit');
    }
    final workouts = await getAllWorkouts(committedOnly: committedOnly);
    return workouts
        .where((workout) {
          if (beforeDate == null) return true;
          if (workout.date.isBefore(beforeDate)) return true;
          return workout.date.isAtSameMomentAs(beforeDate) &&
              beforeId != null &&
              workout.id.compareTo(beforeId) < 0;
        })
        .take(limit)
        .toList(growable: false);
  }

  @override
  Future<List<WorkoutModel>> getPendingWorkouts() async {
    return getAllWorkouts(committedOnly: false).then(
      (workouts) => workouts.where((workout) => workout.isPending).toList(),
    );
  }

  @override
  Future<WorkoutModel?> getWorkout(String id) async {
    return _datasource.workoutsBox.get(id);
  }

  @override
  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      await _datasource.workoutsBox.put(workout.id, workout);
    } catch (error) {
      throw RepositoryException('save workout ${workout.id}', error);
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    try {
      await _datasource.workoutsBox.delete(id);
    } catch (error) {
      throw RepositoryException('delete workout $id', error);
    }
  }

  @override
  Future<int> getTotalExerciseCount(int exerciseTypeIndex) async {
    var total = 0;
    for (final workout in _datasource.workoutsBox.values) {
      if (!workout.isCommitted) continue;
      for (final exercise in workout.exercises) {
        if (exercise.exerciseTypeIndex != exerciseTypeIndex) continue;
        if (exercise.variations.isEmpty) {
          total += exercise.distanceMeters > 0
              ? exercise.distanceMeters.round()
              : exercise.reps;
          continue;
        }
        for (final variation in exercise.variations) {
          for (final set in variation.sets) {
            if (!set.isValid(exercise.trackingMetric)) continue;
            total +=
                set.distanceMeters > 0 ? set.distanceMeters.round() : set.reps;
          }
        }
      }
    }
    return total;
  }

  @override
  Future<double> getAverageFormQuality(int exerciseTypeIndex) async {
    final qualities = <double>[];
    for (final workout in _datasource.workoutsBox.values) {
      if (!workout.isCommitted) continue;
      for (final exercise in workout.exercises) {
        if (exercise.exerciseTypeIndex == exerciseTypeIndex) {
          qualities.add(exercise.formQuality);
        }
      }
    }
    if (qualities.isEmpty) return 0;
    return qualities.reduce((a, b) => a + b) / qualities.length;
  }
}
