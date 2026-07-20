// Central registry of all Hive TypeIds to prevent collisions.
// Values MUST be unique. Never reuse a retired TypeId.
class HiveTypeIds {
  HiveTypeIds._();

  static const int userModel = 0;
  static const int workoutModel = 1;
  static const int exerciseRecord = 2;
  static const int skillModel = 3;
  static const int skillLevelData = 4;
  static const int exerciseRequirement = 5;
  static const int bossBattleModel = 6;
  static const int dailyQuestModel = 7;
  static const int gameStateModel = 8;
  static const int achievementStateModel = 9;
  static const int workoutPlanModel = 10;
  static const int plannedDayModel = 11;
  static const int plannedExerciseModel = 12;
  static const int variationPlanModel = 13;
  static const int variationRecord = 14;
  static const int workoutSetRecord = 15;
}
