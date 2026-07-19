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

  AchievementState copyUnlocked() => AchievementState(
    id: id, name: name, description: description,
    unlocked: true, unlockedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'description': description,
    'unlocked': unlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory AchievementState.fromJson(Map<String, dynamic> json) => AchievementState(
    id: json['id'] as String,
    name: json['name'] as String,
    description: json['description'] as String,
    unlocked: json['unlocked'] as bool? ?? false,
    unlockedAt: json['unlockedAt'] != null
        ? DateTime.parse(json['unlockedAt'] as String)
        : null,
  );
}

class AchievementCatalog {
  static const firstWorkout = 'first_workout';
  static const level5 = 'level_5';
  static const hundredPushUps = '100_pushups';
  static const sevenDayStreak = '7_day_streak';

  static List<AchievementState> defaults() => [
    const AchievementState(id: firstWorkout, name: 'First Workout',
        description: 'Complete your first workout'),
    const AchievementState(id: level5, name: 'Rising Star',
        description: 'Reach Level 5'),
    const AchievementState(id: hundredPushUps, name: 'Push Up Master',
        description: 'Complete 100 Push Ups total'),
    const AchievementState(id: sevenDayStreak, name: 'Dedicated',
        description: 'Maintain a 7-day streak'),
  ];
}
