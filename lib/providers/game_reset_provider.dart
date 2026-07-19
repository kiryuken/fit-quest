import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'achievement_provider.dart';
import 'initialization_provider.dart';
import 'quest_provider.dart';
import 'user_provider.dart';

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

    _ref.invalidate(userProvider);
    _ref.invalidate(questProvider);
    _ref.invalidate(achievementProvider);
    _ref.invalidate(initializationProvider);
  }
}
