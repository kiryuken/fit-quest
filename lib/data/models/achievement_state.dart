class AchievementState {
  final String id;
  final String name;
  final String description;
  final bool unlocked;
  final DateTime? unlockedAt;

  const AchievementState({
    required this.id,
    required this.name,
    required this.description,
    this.unlocked = false,
    this.unlockedAt,
  });

  AchievementState copyUnlocked({DateTime? at}) => AchievementState(
        id: id,
        name: name,
        description: description,
        unlocked: true,
        unlockedAt: at ?? DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'unlocked': unlocked,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory AchievementState.fromJson(Map<String, dynamic> json) {
    return AchievementState(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      unlocked: json['unlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] == null
          ? null
          : DateTime.parse(json['unlockedAt'] as String),
    );
  }
}

class AchievementCatalog {
  AchievementCatalog._();

  static const awakening = 'awakening';
  static const firstWorkout = awakening;
  static const habitForged = 'habit_forged';
  static const foundationBuilt = 'foundation_built';
  static const bodyReforged = 'body_reforged';
  static const ironYear = 'iron_year';
  static const level5 = 'level_5';
  static const hundredPushUps = '100_pushups';
  static const sevenDayStreak = '7_day_streak';

  static const milestoneTitles = <String, String>{
    awakening: 'Awakened',
    habitForged: 'Habit Forged',
    foundationBuilt: 'Foundation Builder',
    bodyReforged: 'Body Reforged',
    ironYear: 'Iron Consistent',
  };

  static List<AchievementState> defaults() => const [
        AchievementState(
          id: awakening,
          name: 'Awakening',
          description: 'Complete your first valid training session',
        ),
        AchievementState(
          id: habitForged,
          name: 'Habit Forged',
          description: 'Train for 4 weeks with at least 75% adherence',
        ),
        AchievementState(
          id: foundationBuilt,
          name: 'Foundation Built',
          description:
              'Reach 12 weeks, 80% adherence, and improve 2 movement families',
        ),
        AchievementState(
          id: bodyReforged,
          name: 'Body Reforged',
          description:
              'Reach 24 weeks, 80% adherence, and improve 3 movement families',
        ),
        AchievementState(
          id: ironYear,
          name: 'Iron Year',
          description:
              'Reach 52 weeks, 80% adherence, and improve 5 movement families',
        ),
        AchievementState(
          id: level5,
          name: 'Rising Star',
          description: 'Reach Level 5',
        ),
        AchievementState(
          id: hundredPushUps,
          name: 'Push Up Master',
          description: 'Complete 100 Push Ups total',
        ),
        AchievementState(
          id: sevenDayStreak,
          name: 'Dedicated',
          description: 'Complete 7 scheduled training days',
        ),
      ];
}
