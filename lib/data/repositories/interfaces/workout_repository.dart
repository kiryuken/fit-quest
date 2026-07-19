import '../../models/workout_model.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutModel>> getAllWorkouts();
  Future<WorkoutModel?> getWorkout(String id);
  Future<void> saveWorkout(WorkoutModel workout);
  Future<void> deleteWorkout(String id);
  Future<int> getTotalExerciseCount(int exerciseTypeIndex);
  Future<double> getAverageFormQuality(int exerciseTypeIndex);
}
