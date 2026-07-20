import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/datasources/hive_datasource.dart';
import '../data/repositories/implementations/user_repository_impl.dart';
import '../data/repositories/implementations/workout_repository_impl.dart';
import '../data/repositories/implementations/skill_repository_impl.dart';
import '../data/repositories/implementations/boss_repository_impl.dart';
import '../data/repositories/implementations/workout_plan_repository_impl.dart';
import '../core/time/app_clock.dart';

final clockProvider = Provider<AppClock>((ref) => const SystemAppClock());

final hiveDatasourceProvider = Provider<HiveDatasource>((ref) {
  return HiveDatasource();
});

final userRepositoryProvider = Provider<UserRepositoryImpl>((ref) {
  return UserRepositoryImpl(
    ref.watch(hiveDatasourceProvider),
    clock: ref.watch(clockProvider),
  );
});

final workoutPlanRepositoryProvider =
    Provider<WorkoutPlanRepositoryImpl>((ref) {
  return WorkoutPlanRepositoryImpl(ref.watch(hiveDatasourceProvider));
});

final workoutRepositoryProvider = Provider<WorkoutRepositoryImpl>((ref) {
  return WorkoutRepositoryImpl(ref.watch(hiveDatasourceProvider));
});

final skillRepositoryProvider = Provider<SkillRepositoryImpl>((ref) {
  return SkillRepositoryImpl(ref.watch(hiveDatasourceProvider));
});

final bossRepositoryProvider = Provider<BossRepositoryImpl>((ref) {
  return BossRepositoryImpl(ref.watch(hiveDatasourceProvider));
});

enum AppInitState { uninitialized, initializing, ready, error }

final initializationProvider = FutureProvider<AppInitState>((ref) async {
  try {
    final datasource = ref.watch(hiveDatasourceProvider);
    await datasource.initialize();

    // Seed default data if first run
    final skillRepo = ref.watch(skillRepositoryProvider);
    await skillRepo.seedDefaultSkills();

    final bossRepo = ref.watch(bossRepositoryProvider);
    await bossRepo.seedDefaultBosses();

    return AppInitState.ready;
  } catch (e) {
    return AppInitState.error;
  }
});
