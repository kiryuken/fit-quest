import 'package:hive/hive.dart';
import '../../core/constants/hive_type_ids.dart';
import '../../core/enums/exercise_type.dart';

part 'workout_model.g.dart';

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
  final Map<int, int> statXpGained; // StatType index -> XP

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

  WorkoutModel({
    required this.id,
    required this.date,
    this.durationSeconds = 0,
    this.exercises = const [],
    this.totalXpEarned = 0,
    this.statXpGained = const {},
    this.completed = false,
    this.notes,
    this.averageFormQuality = 0.0,
    this.bossDamageDealt = 0,
    required this.createdAt,
  });

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
    );
  }
}

@HiveType(typeId: HiveTypeIds.exerciseRecord)
class ExerciseRecord extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int exerciseTypeIndex; // ExerciseType index

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

  ExerciseRecord({
    required this.id,
    required this.exerciseTypeIndex,
    this.sets = 1,
    this.reps = 0,
    this.weight = 0.0,
    this.durationSeconds = 0,
    this.formQuality = 0.7,
    this.xpEarned = 0,
    this.distanceMeters = 0.0,
    this.caloriesBurned = 0,
    this.orderIndex = 0,
  });

  ExerciseType get exerciseType => ExerciseType.values[exerciseTypeIndex];

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
    );
  }
}
