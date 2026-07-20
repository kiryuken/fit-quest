import 'package:hive/hive.dart';

import '../../core/constants/hive_type_ids.dart';
import '../../core/enums/exercise_tracking_metric.dart';
import '../../core/enums/exercise_type.dart';

part 'workout_plan_model.g.dart';

enum WorkoutDayType { push, pull, legs, conditioning, rest }

@HiveType(typeId: HiveTypeIds.workoutPlanModel)
class WorkoutPlanModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String presetId;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final List<PlannedDayModel> days;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final DateTime updatedAt;

  WorkoutPlanModel({
    required this.id,
    required this.presetId,
    required this.name,
    required this.days,
    required this.createdAt,
    required this.updatedAt,
  });

  PlannedDayModel dayFor(DateTime date) {
    return days.firstWhere((day) => day.weekday == date.weekday);
  }

  WorkoutPlanModel copyWith({
    String? id,
    String? presetId,
    String? name,
    List<PlannedDayModel>? days,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutPlanModel(
      id: id ?? this.id,
      presetId: presetId ?? this.presetId,
      name: name ?? this.name,
      days: days ?? this.days,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: HiveTypeIds.plannedDayModel)
class PlannedDayModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int weekday;

  @HiveField(2)
  final String label;

  @HiveField(3)
  final int dayTypeIndex;

  @HiveField(4)
  final bool isOptional;

  @HiveField(5)
  final List<PlannedExerciseModel> exercises;

  PlannedDayModel({
    required this.id,
    required this.weekday,
    required this.label,
    required this.dayTypeIndex,
    this.isOptional = false,
    this.exercises = const [],
  });

  WorkoutDayType get dayType => WorkoutDayType.values[dayTypeIndex];
  bool get isRest => dayType == WorkoutDayType.rest;
  bool get countsForStreak => !isRest && !isOptional;

  int get plannedSetCount => exercises
      .where((exercise) => !exercise.isOptional)
      .expand((exercise) => exercise.variations)
      .fold(0, (total, variation) => total + variation.targetSets);

  PlannedDayModel copyWith({
    String? id,
    int? weekday,
    String? label,
    int? dayTypeIndex,
    bool? isOptional,
    List<PlannedExerciseModel>? exercises,
  }) {
    return PlannedDayModel(
      id: id ?? this.id,
      weekday: weekday ?? this.weekday,
      label: label ?? this.label,
      dayTypeIndex: dayTypeIndex ?? this.dayTypeIndex,
      isOptional: isOptional ?? this.isOptional,
      exercises: exercises ?? this.exercises,
    );
  }
}

@HiveType(typeId: HiveTypeIds.plannedExerciseModel)
class PlannedExerciseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int exerciseTypeIndex;

  @HiveField(2)
  final String movementId;

  @HiveField(3)
  final String name;

  @HiveField(4)
  final int trackingMetricIndex;

  @HiveField(5)
  final List<VariationPlanModel> variations;

  @HiveField(6)
  final bool isOptional;

  PlannedExerciseModel({
    required this.id,
    required this.exerciseTypeIndex,
    required this.movementId,
    required this.name,
    required this.trackingMetricIndex,
    required this.variations,
    this.isOptional = false,
  });

  ExerciseType get exerciseType => ExerciseType.values[exerciseTypeIndex];
  ExerciseTrackingMetric get trackingMetric =>
      ExerciseTrackingMetric.values[trackingMetricIndex];

  PlannedExerciseModel copyWith({
    String? id,
    int? exerciseTypeIndex,
    String? movementId,
    String? name,
    int? trackingMetricIndex,
    List<VariationPlanModel>? variations,
    bool? isOptional,
  }) {
    return PlannedExerciseModel(
      id: id ?? this.id,
      exerciseTypeIndex: exerciseTypeIndex ?? this.exerciseTypeIndex,
      movementId: movementId ?? this.movementId,
      name: name ?? this.name,
      trackingMetricIndex: trackingMetricIndex ?? this.trackingMetricIndex,
      variations: variations ?? this.variations,
      isOptional: isOptional ?? this.isOptional,
    );
  }
}

@HiveType(typeId: HiveTypeIds.variationPlanModel)
class VariationPlanModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int targetSets;

  @HiveField(3)
  final int targetValue;

  @HiveField(4)
  final double targetLoadKg;

  @HiveField(5)
  final double difficultyMultiplier;

  VariationPlanModel({
    required this.id,
    required this.name,
    required this.targetSets,
    required this.targetValue,
    this.targetLoadKg = 0,
    this.difficultyMultiplier = 1,
  });

  VariationPlanModel copyWith({
    String? id,
    String? name,
    int? targetSets,
    int? targetValue,
    double? targetLoadKg,
    double? difficultyMultiplier,
  }) {
    return VariationPlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      targetSets: targetSets ?? this.targetSets,
      targetValue: targetValue ?? this.targetValue,
      targetLoadKg: targetLoadKg ?? this.targetLoadKg,
      difficultyMultiplier: difficultyMultiplier ?? this.difficultyMultiplier,
    );
  }
}
