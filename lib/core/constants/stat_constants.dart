import '../enums/stat_type.dart';

class StatConstants {
  StatConstants._();

  static const int defaultStatValue = 1;
  static const int maxStatCap = 100;

  static Map<StatType, int> defaultStats() {
    return {for (final s in StatType.values) s: defaultStatValue};
  }
}
