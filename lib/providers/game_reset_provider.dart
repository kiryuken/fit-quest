import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/hive_datasource.dart';
import '../domain/services/workout_completion_service.dart';
import 'achievement_provider.dart';
import 'initialization_provider.dart';
import 'quest_provider.dart';
import 'settings_preferences_provider.dart';
import 'user_provider.dart';
import 'weekly_plan_provider.dart';

final gameResetServiceProvider = Provider<GameResetService>(
  GameResetService.new,
);

class GameResetService {
  final Ref _ref;

  GameResetService(this._ref);

  Future<void> resetAllData() async {
    final datasource = _ref.read(hiveDatasourceProvider);
    await datasource.userBox.clear();
    await datasource.workoutsBox.clear();
    await datasource.skillsBox.clear();
    await datasource.bossesBox.clear();
    await datasource.gameStateBox.clear();
    await datasource.gameStateBox.put(
      '_dataVersion',
      HiveDatasource.currentDataVersion,
    );

    _ref.invalidate(userProvider);
    _ref.invalidate(questProvider);
    _ref.invalidate(achievementProvider);
    _ref.invalidate(weeklyPlanProvider);
    _ref.invalidate(workoutCompletionServiceProvider);
    _ref.invalidate(settingsPreferencesProvider);
    _ref.invalidate(initializationProvider);
  }
}
