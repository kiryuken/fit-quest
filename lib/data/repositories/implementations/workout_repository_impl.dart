import 'package:flutter/foundation.dart';
import '../../datasources/hive_datasource.dart';
import '../../models/workout_model.dart';
import '../interfaces/workout_repository.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  static const int retentionDays = 90;

  final HiveDatasource _datasource;
  WorkoutRepositoryImpl(this._datasource);

  @override
  Future<List<WorkoutModel>> getAllWorkouts() async {
    final cutoff = DateTime.now().subtract(const Duration(days: retentionDays));
    return _datasource.workoutsBox.values
        .where((w) => w.date.isAfter(cutoff))
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Future<WorkoutModel?> getWorkout(String id) async {
    return _datasource.workoutsBox.get(id);
  }

  @override
  Future<void> saveWorkout(WorkoutModel workout) async {
    try {
      await _datasource.workoutsBox.put(workout.id, workout);
      pruneOldWorkouts();
    } catch (e) {
      debugPrint('[WorkoutRepo] Failed to save workout: $e');
    }
  }

  @override
  Future<void> deleteWorkout(String id) async {
    try {
      await _datasource.workoutsBox.delete(id);
    } catch (e) {
      debugPrint('[WorkoutRepo] Failed to delete workout: $e');
    }
  }

  void pruneOldWorkouts() {
    final cutoff = DateTime.now().subtract(const Duration(days: retentionDays));
    final keysToDelete = _datasource.workoutsBox.keys.where((k) {
      final w = _datasource.workoutsBox.get(k);
      return w != null && w.date.isBefore(cutoff);
    }).toList();
    for (final key in keysToDelete) {
      _datasource.workoutsBox.delete(key);
    }
  }

  @override
  Future<int> getTotalExerciseCount(int exerciseTypeIndex) async {
    final cutoff = DateTime.now().subtract(const Duration(days: retentionDays));
    int total = 0;
    for (final w in _datasource.workoutsBox.values) {
      if (!w.date.isAfter(cutoff)) continue;
      for (final e in w.exercises) {
        if (e.exerciseTypeIndex == exerciseTypeIndex) {
          total +=
              e.distanceMeters > 0 ? e.distanceMeters.round() : e.sets * e.reps;
        }
      }
    }
    return total;
  }

  @override
  Future<double> getAverageFormQuality(int exerciseTypeIndex) async {
    final cutoff = DateTime.now().subtract(const Duration(days: retentionDays));
    final qualities = <double>[];
    for (final w in _datasource.workoutsBox.values) {
      if (!w.date.isAfter(cutoff)) continue;
      for (final e in w.exercises) {
        if (e.exerciseTypeIndex == exerciseTypeIndex) {
          qualities.add(e.formQuality);
        }
      }
    }
    if (qualities.isEmpty) return 0.0;
    return qualities.reduce((a, b) => a + b) / qualities.length;
  }
}
