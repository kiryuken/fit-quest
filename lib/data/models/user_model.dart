import 'package:hive/hive.dart';

import '../../core/constants/hive_type_ids.dart';
import '../../core/constants/stat_constants.dart';
import '../../core/enums/stat_type.dart';

part 'user_model.g.dart';

@HiveType(typeId: HiveTypeIds.userModel)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int level;

  @HiveField(3)
  final int currentXp;

  @HiveField(4)
  final int totalXp;

  @HiveField(5)
  final Map<int, double> stats;

  @HiveField(6)
  final List<String> unlockedSkills;

  @HiveField(7)
  final Map<String, int> skillLevels;

  @HiveField(8)
  final int currentHp;

  @HiveField(9)
  final int maxHp;

  @HiveField(10)
  final int streak;

  @HiveField(11)
  final int longestStreak;

  @HiveField(12)
  final int streakShields;

  @HiveField(13)
  final DateTime? lastWorkoutAt;

  @HiveField(14)
  final String title;

  @HiveField(15)
  final List<String> unlockedTitles;

  @HiveField(16)
  final int bossBattlesWon;

  @HiveField(17)
  final int totalWorkoutsCompleted;

  @HiveField(18)
  final DateTime createdAt;

  @HiveField(19)
  final DateTime updatedAt;

  @HiveField(20)
  final int age;

  @HiveField(21)
  final double height;

  @HiveField(22)
  final double weight;

  @HiveField(23)
  final String fitnessLevel;

  @HiveField(24)
  final int? preferredFocusIndex;

  @HiveField(25)
  final Map<String, int> masteryXp;

  @HiveField(26)
  final int workoutXpToday;

  @HiveField(27)
  final int questXpToday;

  @HiveField(28)
  final DateTime xpBudgetDate;

  @HiveField(29)
  final Map<String, int> processedEventXp;

  @HiveField(30)
  final int scheduledCompletions;

  @HiveField(31)
  final List<String> personalRecordMovementIds;

  @HiveField(32)
  final DateTime? lastStreakWorkoutAt;

  @HiveField(33)
  final List<DateTime> completedScheduledDates;

  UserModel({
    required this.id,
    required this.name,
    this.level = 1,
    this.currentXp = 0,
    this.totalXp = 0,
    this.stats = const {},
    this.unlockedSkills = const [],
    this.skillLevels = const {},
    this.currentHp = 155,
    this.maxHp = 155,
    this.streak = 0,
    this.longestStreak = 0,
    this.streakShields = 0,
    this.lastWorkoutAt,
    this.title = '',
    this.unlockedTitles = const [],
    this.bossBattlesWon = 0,
    this.totalWorkoutsCompleted = 0,
    required this.createdAt,
    required this.updatedAt,
    this.age = 18,
    this.height = 170,
    this.weight = 70,
    this.fitnessLevel = 'Beginner',
    this.preferredFocusIndex,
    this.masteryXp = const {},
    this.workoutXpToday = 0,
    this.questXpToday = 0,
    DateTime? xpBudgetDate,
    this.processedEventXp = const {},
    this.scheduledCompletions = 0,
    this.personalRecordMovementIds = const [],
    this.lastStreakWorkoutAt,
    this.completedScheduledDates = const [],
  }) : xpBudgetDate = xpBudgetDate ??
            DateTime(updatedAt.year, updatedAt.month, updatedAt.day);

  double getStatValue(StatType stat) =>
      stats[stat.index] ?? StatConstants.defaultStatValue;

  /// Rounded value for combat and whole-number requirement checks.
  int getStat(StatType stat) => getStatValue(stat).round();

  bool hasSkill(String skillId) => unlockedSkills.contains(skillId);
  int skillLevel(String skillId) => skillLevels[skillId] ?? 0;

  UserModel copyWith({
    String? id,
    String? name,
    int? level,
    int? currentXp,
    int? totalXp,
    Map<int, double>? stats,
    List<String>? unlockedSkills,
    Map<String, int>? skillLevels,
    int? currentHp,
    int? maxHp,
    int? streak,
    int? longestStreak,
    int? streakShields,
    DateTime? lastWorkoutAt,
    String? title,
    List<String>? unlockedTitles,
    int? bossBattlesWon,
    int? totalWorkoutsCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? age,
    double? height,
    double? weight,
    String? fitnessLevel,
    int? preferredFocusIndex,
    Map<String, int>? masteryXp,
    int? workoutXpToday,
    int? questXpToday,
    DateTime? xpBudgetDate,
    Map<String, int>? processedEventXp,
    int? scheduledCompletions,
    List<String>? personalRecordMovementIds,
    DateTime? lastStreakWorkoutAt,
    List<DateTime>? completedScheduledDates,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      currentXp: currentXp ?? this.currentXp,
      totalXp: totalXp ?? this.totalXp,
      stats: stats ?? this.stats,
      unlockedSkills: unlockedSkills ?? this.unlockedSkills,
      skillLevels: skillLevels ?? this.skillLevels,
      currentHp: currentHp ?? this.currentHp,
      maxHp: maxHp ?? this.maxHp,
      streak: streak ?? this.streak,
      longestStreak: longestStreak ?? this.longestStreak,
      streakShields: streakShields ?? this.streakShields,
      lastWorkoutAt: lastWorkoutAt ?? this.lastWorkoutAt,
      title: title ?? this.title,
      unlockedTitles: unlockedTitles ?? this.unlockedTitles,
      bossBattlesWon: bossBattlesWon ?? this.bossBattlesWon,
      totalWorkoutsCompleted:
          totalWorkoutsCompleted ?? this.totalWorkoutsCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      preferredFocusIndex: preferredFocusIndex ?? this.preferredFocusIndex,
      masteryXp: masteryXp ?? this.masteryXp,
      workoutXpToday: workoutXpToday ?? this.workoutXpToday,
      questXpToday: questXpToday ?? this.questXpToday,
      xpBudgetDate: xpBudgetDate ?? this.xpBudgetDate,
      processedEventXp: processedEventXp ?? this.processedEventXp,
      scheduledCompletions: scheduledCompletions ?? this.scheduledCompletions,
      personalRecordMovementIds:
          personalRecordMovementIds ?? this.personalRecordMovementIds,
      lastStreakWorkoutAt: lastStreakWorkoutAt ?? this.lastStreakWorkoutAt,
      completedScheduledDates:
          completedScheduledDates ?? this.completedScheduledDates,
    );
  }
}
