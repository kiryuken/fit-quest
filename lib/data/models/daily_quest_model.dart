import '../../core/data/workout_plan_catalog.dart';
import '../../core/enums/exercise_tracking_metric.dart';
import 'workout_plan_model.dart';

class DailyQuestModel {
  final String id;
  final String title;
  final String metricSlug;
  final int target;
  final int progress;
  final int expReward;
  final bool isCompleted;
  final DateTime date;
  final List<String> appliedEventIds;

  const DailyQuestModel({
    required this.id,
    required this.title,
    required this.metricSlug,
    required this.target,
    this.progress = 0,
    required this.expReward,
    this.isCompleted = false,
    required this.date,
    this.appliedEventIds = const [],
  });

  DailyQuestModel addProgress(int amount, {String? eventId}) {
    if (amount <= 0 || (eventId != null && appliedEventIds.contains(eventId))) {
      return this;
    }
    final newProgress = (progress + amount).clamp(0, target);
    return copyWith(
      progress: newProgress,
      isCompleted: newProgress >= target,
      appliedEventIds:
          eventId == null ? appliedEventIds : [...appliedEventIds, eventId],
    );
  }

  DailyQuestModel copyWith({
    String? id,
    String? title,
    String? metricSlug,
    int? target,
    int? progress,
    int? expReward,
    bool? isCompleted,
    DateTime? date,
    List<String>? appliedEventIds,
  }) {
    return DailyQuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      metricSlug: metricSlug ?? this.metricSlug,
      target: target ?? this.target,
      progress: progress ?? this.progress,
      expReward: expReward ?? this.expReward,
      isCompleted: isCompleted ?? this.isCompleted,
      date: date ?? this.date,
      appliedEventIds: appliedEventIds ?? this.appliedEventIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'metricSlug': metricSlug,
        'target': target,
        'progress': progress,
        'expReward': expReward,
        'isCompleted': isCompleted,
        'date': date.toIso8601String(),
        'appliedEventIds': appliedEventIds,
      };

  factory DailyQuestModel.fromJson(Map<String, dynamic> json) {
    return DailyQuestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      metricSlug: json['metricSlug'] as String,
      target: json['target'] as int,
      progress: json['progress'] as int? ?? 0,
      expReward: json['expReward'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      date: DateTime.parse(json['date'] as String),
      appliedEventIds:
          List<String>.from(json['appliedEventIds'] as List? ?? []),
    );
  }
}

class QuestCatalog {
  QuestCatalog._();

  static List<DailyQuestModel> forDay({
    required WorkoutPlanModel plan,
    required DateTime date,
  }) {
    final day = plan.dayFor(date);
    final normalized = DateTime(date.year, date.month, date.day);
    if (day.isRest) return const [];

    final quests = <DailyQuestModel>[
      DailyQuestModel(
        id: 'workout_count_${_dateKey(normalized)}',
        title: day.isOptional
            ? 'Complete Optional Training'
            : 'Complete ${day.label}',
        metricSlug: 'workout_count',
        target: 1,
        expReward: 1,
        date: normalized,
      ),
    ];

    final exercises =
        day.exercises.where((exercise) => !exercise.isOptional).take(2);
    for (final exercise in exercises) {
      final target = exercise.variations.fold<int>(
        0,
        (total, variation) =>
            total + (variation.targetSets * variation.targetValue),
      );
      final unit = switch (exercise.trackingMetric) {
        ExerciseTrackingMetric.repetitions => 'reps',
        ExerciseTrackingMetric.durationSeconds => 'seconds',
        ExerciseTrackingMetric.distanceMeters => 'meters',
      };
      quests.add(
        DailyQuestModel(
          id: '${exercise.movementId}_${_dateKey(normalized)}',
          title: '${exercise.name}: $target $unit',
          metricSlug: exercise.movementId,
          target: target,
          expReward: 2,
          date: normalized,
        ),
      );
    }
    return quests;
  }

  static List<DailyQuestModel> today({DateTime? now}) {
    final date = now ?? DateTime.now();
    return forDay(
      plan: WorkoutPlanCatalog.create(
        fitnessLevel: 'Intermediate',
        now: date,
      ),
      date: date,
    );
  }

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
