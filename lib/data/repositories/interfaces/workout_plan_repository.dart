import '../../models/workout_plan_model.dart';

abstract interface class WorkoutPlanRepository {
  Future<WorkoutPlanModel?> getPlan();
  Future<void> savePlan(WorkoutPlanModel plan);
  Future<void> deletePlan();
}
