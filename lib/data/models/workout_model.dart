import 'package:hive/hive.dart';

import '../../core/constants/hive_type_ids.dart';
import '../../core/enums/exercise_tracking_metric.dart';
import '../../core/enums/exercise_type.dart';

part 'workout_model.g.dart';

enum WorkoutProcessingState { pending, committed, failed }

@HiveType(typeId: HiveTypeIds.workoutModel)
class WorkoutModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final int durationSeconds;

  @HiveField(3)
  final List<ExerciseRecord> exercises;

  @HiveField(4)
  final int totalXpEarned;

  @HiveField(5)
  final Map<int, int> statXpGained;

  @HiveField(6)
  final bool completed;

  @HiveField(7)
  final String? notes;

  @HiveField(8)
  final double averageFormQuality;

  @HiveField(9)
  final int bossDamageDealt;

  @HiveField(10)
  final DateTime createdAt;

  @HiveField(11)
  final String? planId;

  @HiveField(12)
  final String? plannedDayId;

  @HiveField(13)
  final String eventId;

  @HiveField(14)
  final int processingStateIndex;

  @HiveField(15)
  final double completionRate;

  @HiveField(16)
  final Map<String, int> masteryPoints;

  @HiveField(17)
  final Map<String, double> benchmarkScores;

  @HiveField(18)
  final List<String> personalRecordMovementIds;

  @HiveField(19)
  final bool scheduled;

  @HiveField(20)
  final bool countsForStreak;

  @HiveField(21)
  final DateTime? committedAt;

  @HiveField(22)
  final String? failureMessage;

  WorkoutModel({
    required this.id,
    required this.date,
    this.durationSeconds = 0,
    this.exercises = const [],
    this.totalXpEarned = 0,
    this.statXpGained = const {},
    this.completed = false,
    this.notes,
    this.averageFormQuality = 0,
    this.bossDamageDealt = 0,
    required this.createdAt,
    this.planId,
    this.plannedDayId,
    String? eventId,
    this.processingStateIndex = 0,
    this.completionRate = 0,
    this.masteryPoints = const {},
    this.benchmarkScores = const {},
    this.personalRecordMovementIds = const [],
    this.scheduled = false,
    this.countsForStreak = false,
    this.committedAt,
    this.failureMessage,
  }) : eventId = eventId ?? id;

  WorkoutProcessingState get processingState {
    if (processingStateIndex < 0 ||
        processingStateIndex >= WorkoutProcessingState.values.length) {
      return WorkoutProcessingState.failed;
    }
    return WorkoutProcessingState.values[processingStateIndex];
  }

  bool get isPending => processingState == WorkoutProcessingState.pending;
  bool get isCommitted => processingState == WorkoutProcessingState.committed;

  int get plannedSetCount =>
      exercises.fold(0, (total, exercise) => total + exercise.plannedSetCount);

  int get validSetCount =>
      exercises.fold(0, (total, exercise) => total + exercise.validSetCount);

  int get validExerciseFamilyCount =>
      exercises.where((exercise) => exercise.validSetCount > 0).length;

  WorkoutModel copyWith({
    String? id,
    DateTime? date,
    int? durationSeconds,
    List<ExerciseRecord>? exercises,
    int? totalXpEarned,
    Map<int, int>? statXpGained,
    bool? completed,
    String? notes,
    double? averageFormQuality,
    int? bossDamageDealt,
    DateTime? createdAt,
    String? planId,
    String? plannedDayId,
    String? eventId,
    int? processingStateIndex,
    double? completionRate,
    Map<String, int>? masteryPoints,
    Map<String, double>? benchmarkScores,
    List<String>? personalRecordMovementIds,
    bool? scheduled,
    bool? countsForStreak,
    DateTime? committedAt,
    String? failureMessage,
  }) {
    return WorkoutModel(
      id: id ?? this.id,
      date: date ?? this.date,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      exercises: exercises ?? this.exercises,
      totalXpEarned: totalXpEarned ?? this.totalXpEarned,
      statXpGained: statXpGained ?? this.statXpGained,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
      averageFormQuality: averageFormQuality ?? this.averageFormQuality,
      bossDamageDealt: bossDamageDealt ?? this.bossDamageDealt,
      createdAt: createdAt ?? this.createdAt,
      planId: planId ?? this.planId,
      plannedDayId: plannedDayId ?? this.plannedDayId,
      eventId: eventId ?? this.eventId,
      processingStateIndex: processingStateIndex ?? this.processingStateIndex,
      completionRate: completionRate ?? this.completionRate,
      masteryPoints: masteryPoints ?? this.masteryPoints,
      benchmarkScores: benchmarkScores ?? this.benchmarkScores,
      personalRecordMovementIds:
          personalRecordMovementIds ?? this.personalRecordMovementIds,
      scheduled: scheduled ?? this.scheduled,
      countsForStreak: countsForStreak ?? this.countsForStreak,
      committedAt: committedAt ?? this.committedAt,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }
}

@HiveType(typeId: HiveTypeIds.exerciseRecord)
class ExerciseRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int exerciseTypeIndex;

  @HiveField(2)
  final int sets;

  @HiveField(3)
  final int reps;

  @HiveField(4)
  final double weight;

  @HiveField(5)
  final int durationSeconds;

  @HiveField(6)
  final double formQuality;

  @HiveField(7)
  final int xpEarned;

  @HiveField(8)
  final double distanceMeters;

  @HiveField(9)
  final int caloriesBurned;

  @HiveField(10)
  final int orderIndex;

  @HiveField(11)
  final String movementId;

  @HiveField(12)
  final String displayName;

  @HiveField(13)
  final int trackingMetricIndex;

  @HiveField(14)
  final List<VariationRecord> variations;

  @HiveField(15)
  final int masteryEarned;

  @HiveField(16)
  final bool isPersonalRecord;

  ExerciseRecord({
    required this.id,
    required this.exerciseTypeIndex,
    this.sets = 1,
    this.reps = 0,
    this.weight = 0,
    this.durationSeconds = 0,
    this.formQuality = 0.8,
    this.xpEarned = 0,
    this.distanceMeters = 0,
    this.caloriesBurned = 0,
    this.orderIndex = 0,
    String? movementId,
    String? displayName,
    this.trackingMetricIndex = 0,
    this.variations = const [],
    this.masteryEarned = 0,
    this.isPersonalRecord = false,
  })  : movementId = movementId ?? _safeExerciseType(exerciseTypeIndex).name,
        displayName =
            displayName ?? _safeExerciseType(exerciseTypeIndex).displayName;

  ExerciseType get exerciseType => _safeExerciseType(exerciseTypeIndex);
  ExerciseTrackingMetric get trackingMetric {
    if (trackingMetricIndex < 0 ||
        trackingMetricIndex >= ExerciseTrackingMetric.values.length) {
      return ExerciseTrackingMetric.repetitions;
    }
    return ExerciseTrackingMetric.values[trackingMetricIndex];
  }

  int get plannedSetCount {
    if (variations.isNotEmpty) {
      return variations.fold(
        0,
        (total, variation) => total + variation.sets.length,
      );
    }
    return sets;
  }

  int get validSetCount {
    if (variations.isNotEmpty) {
      return variations.fold(
        0,
        (total, variation) => total + variation.validSetCount(trackingMetric),
      );
    }
    final valid = trackingMetric.isValid(
      reps: reps,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
    );
    return valid ? sets : 0;
  }

  ExerciseRecord copyWith({
    String? id,
    int? exerciseTypeIndex,
    int? sets,
    int? reps,
    double? weight,
    int? durationSeconds,
    double? formQuality,
    int? xpEarned,
    double? distanceMeters,
    int? caloriesBurned,
    int? orderIndex,
    String? movementId,
    String? displayName,
    int? trackingMetricIndex,
    List<VariationRecord>? variations,
    int? masteryEarned,
    bool? isPersonalRecord,
  }) {
    return ExerciseRecord(
      id: id ?? this.id,
      exerciseTypeIndex: exerciseTypeIndex ?? this.exerciseTypeIndex,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      formQuality: formQuality ?? this.formQuality,
      xpEarned: xpEarned ?? this.xpEarned,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      orderIndex: orderIndex ?? this.orderIndex,
      movementId: movementId ?? this.movementId,
      displayName: displayName ?? this.displayName,
      trackingMetricIndex: trackingMetricIndex ?? this.trackingMetricIndex,
      variations: variations ?? this.variations,
      masteryEarned: masteryEarned ?? this.masteryEarned,
      isPersonalRecord: isPersonalRecord ?? this.isPersonalRecord,
    );
  }
}

@HiveType(typeId: HiveTypeIds.variationRecord)
class VariationRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double difficultyMultiplier;

  @HiveField(3)
  final List<WorkoutSetRecord> sets;

  VariationRecord({
    required this.id,
    required this.name,
    this.difficultyMultiplier = 1,
    this.sets = const [],
  });

  int validSetCount(ExerciseTrackingMetric metric) =>
      sets.where((set) => set.isValid(metric)).length;

  VariationRecord copyWith({
    String? id,
    String? name,
    double? difficultyMultiplier,
    List<WorkoutSetRecord>? sets,
  }) {
    return VariationRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      difficultyMultiplier: difficultyMultiplier ?? this.difficultyMultiplier,
      sets: sets ?? this.sets,
    );
  }
}

@HiveType(typeId: HiveTypeIds.workoutSetRecord)
class WorkoutSetRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int reps;

  @HiveField(2)
  final int durationSeconds;

  @HiveField(3)
  final double distanceMeters;

  @HiveField(4)
  final double loadKg;

  @HiveField(5)
  final int rpe;

  @HiveField(6)
  final bool completed;

  WorkoutSetRecord({
    required this.id,
    this.reps = 0,
    this.durationSeconds = 0,
    this.distanceMeters = 0,
    this.loadKg = 0,
    this.rpe = 7,
    this.completed = false,
  });

  bool isValid(ExerciseTrackingMetric metric) {
    if (!completed || rpe < 1 || rpe > 10 || loadKg < 0) return false;
    return metric.isValid(
      reps: reps,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
    );
  }

  WorkoutSetRecord copyWith({
    String? id,
    int? reps,
    int? durationSeconds,
    double? distanceMeters,
    double? loadKg,
    int? rpe,
    bool? completed,
  }) {
    return WorkoutSetRecord(
      id: id ?? this.id,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      loadKg: loadKg ?? this.loadKg,
      rpe: rpe ?? this.rpe,
      completed: completed ?? this.completed,
    );
  }
}

ExerciseType _safeExerciseType(int index) {
  if (index < 0 || index >= ExerciseType.values.length) {
    return ExerciseType.pushUp;
  }
  return ExerciseType.values[index];
}
