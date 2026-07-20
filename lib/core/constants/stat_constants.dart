import '../enums/stat_type.dart';

class StatConstants {
  StatConstants._();

  static const double defaultStatValue = 10;
  static const double maxStatCap = 50;

  static Map<StatType, double> defaultStats() {
    return {for (final s in StatType.values) s: defaultStatValue};
  }
}
