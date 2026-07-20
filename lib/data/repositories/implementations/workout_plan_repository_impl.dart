import '../../datasources/hive_datasource.dart';
import '../../models/workout_plan_model.dart';
import '../interfaces/workout_plan_repository.dart';
import '../repository_exception.dart';

class WorkoutPlanRepositoryImpl implements WorkoutPlanRepository {
  static const String planKey = 'workout_plan_v2';

  final HiveDatasource _datasource;

  WorkoutPlanRepositoryImpl(this._datasource);

  @override
  Future<WorkoutPlanModel?> getPlan() async {
    final value = _datasource.gameStateBox.get(planKey);
    return value is WorkoutPlanModel ? value : null;
  }

  @override
  Future<void> savePlan(WorkoutPlanModel plan) async {
    try {
      await _datasource.gameStateBox.put(planKey, plan);
    } catch (error) {
      throw RepositoryException('save workout plan', error);
    }
  }

  @override
  Future<void> deletePlan() async {
    try {
      await _datasource.gameStateBox.delete(planKey);
    } catch (error) {
      throw RepositoryException('delete workout plan', error);
    }
  }
}
