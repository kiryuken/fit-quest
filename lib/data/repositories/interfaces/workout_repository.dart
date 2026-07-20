import '../../models/workout_model.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutModel>> getAllWorkouts({bool committedOnly = true});
  Future<List<WorkoutModel>> getWorkouts({
    DateTime? beforeDate,
    String? beforeId,
    int limit = 20,
    bool committedOnly = true,
  });
  Future<List<WorkoutModel>> getPendingWorkouts();
  Future<WorkoutModel?> getWorkout(String id);
  Future<void> saveWorkout(WorkoutModel workout);
  Future<void> deleteWorkout(String id);
  Future<int> getTotalExerciseCount(int exerciseTypeIndex);
  Future<double> getAverageFormQuality(int exerciseTypeIndex);
}
