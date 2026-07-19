import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/hive_datasource.dart';
import 'initialization_provider.dart';

abstract interface class SettingsPreferences {
  bool get notificationsEnabled;

  Future<void> setNotificationsEnabled(bool value);
}

final settingsPreferencesProvider = Provider<SettingsPreferences>((ref) {
  return HiveSettingsPreferences(ref.watch(hiveDatasourceProvider));
});

class HiveSettingsPreferences implements SettingsPreferences {
  final HiveDatasource _datasource;

  HiveSettingsPreferences(this._datasource);

  @override
  bool get notificationsEnabled => _datasource.gameStateBox.get(
        'notifications_enabled',
        defaultValue: false,
      ) as bool;

  @override
  Future<void> setNotificationsEnabled(bool value) async {
    await _datasource.gameStateBox.put('notifications_enabled', value);
  }
}
