class DailyQuestModel {
  final String id;
  final String title;
  final int target;
  final int progress;
  final int expReward;
  final bool isCompleted;
  final DateTime date;

  const DailyQuestModel({
    required this.id,
    required this.title,
    required this.target,
    this.progress = 0,
    required this.expReward,
    this.isCompleted = false,
    required this.date,
  });

  DailyQuestModel addProgress(int amount) {
    final newProgress = progress + amount;
    return DailyQuestModel(
      id: id, title: title, target: target,
      progress: newProgress > target ? target : newProgress,
      expReward: expReward,
      isCompleted: newProgress >= target,
      date: date,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id, 'title': title, 'target': target,
    'progress': progress, 'expReward': expReward,
    'isCompleted': isCompleted, 'date': date.toIso8601String(),
  };

  factory DailyQuestModel.fromJson(Map<String, dynamic> json) => DailyQuestModel(
    id: json['id'] as String,
    title: json['title'] as String,
    target: json['target'] as int,
    progress: json['progress'] as int? ?? 0,
    expReward: json['expReward'] as int,
    isCompleted: json['isCompleted'] as bool? ?? false,
    date: DateTime.parse(json['date'] as String),
  );
}

class QuestCatalog {
  static const _pool = [
    ('Push Ups', 'pushup', 20, 50),
    ('Pull Ups', 'pullup', 10, 60),
    ('Run (meters)', 'running', 3000, 45),
    ('Jump Rope (reps)', 'jump_rope', 200, 40),
    ('Boxing Combos', 'boxing', 30, 55),
    ('Plank (seconds)', 'plank', 120, 35),
    ('Lunges', 'lunges', 40, 40),
    ('Burpees', 'burpees', 15, 50),
    ('Squats', 'squats', 50, 35),
    ('High Knees (reps)', 'high_knees', 100, 30),
    ('Complete 2 Workouts', 'workout_count', 2, 70),
    ('Drink 2L Water', 'water', 2, 30),
  ];

  static List<DailyQuestModel> today() {
    final now = DateTime.now();
    final d = DateTime(now.year, now.month, now.day);
    final seed = d.millisecondsSinceEpoch ~/ 86400000;

    // Deterministic shuffle based on date seed
    final indices = List.generate(_pool.length, (i) => i);
    _seededShuffle(indices, seed);

    // Pick first 3 for today
    final selected = indices.take(3).toList();

    return selected.map((i) {
      final entry = _pool[i];
      return DailyQuestModel(
        id: '${entry.$2}_$d',
        title: entry.$1,
        target: entry.$3,
        expReward: entry.$4,
        date: d,
      );
    }).toList();
  }

  /// Fisher-Yates shuffle with a simple LCG seed.
  static void _seededShuffle(List<int> list, int seed) {
    var s = seed.abs();
    for (var i = list.length - 1; i > 0; i--) {
      s = (s * 1103515245 + 12345) & 0x7FFFFFFF;
      final j = s % (i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
  }
}
