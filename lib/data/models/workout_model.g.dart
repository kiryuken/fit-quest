// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_model.dart';

class WorkoutModelAdapter extends TypeAdapter<WorkoutModel> {
  @override
  final int typeId = HiveTypeIds.workoutModel;

  @override
  WorkoutModel read(BinaryReader reader) {
    final fields = _readWorkoutFields(reader);
    return WorkoutModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      durationSeconds: fields[2] as int? ?? 0,
      exercises: (fields[3] as List?)?.cast<ExerciseRecord>() ?? [],
      totalXpEarned: fields[4] as int? ?? 0,
      statXpGained: Map<int, int>.from(fields[5] as Map? ?? {}),
      completed: fields[6] as bool? ?? false,
      notes: fields[7] as String?,
      averageFormQuality: (fields[8] as num?)?.toDouble() ?? 0,
      bossDamageDealt: fields[9] as int? ?? 0,
      createdAt: fields[10] as DateTime,
      planId: fields[11] as String?,
      plannedDayId: fields[12] as String?,
      eventId: fields[13] as String?,
      processingStateIndex: fields[14] as int? ?? 0,
      completionRate: (fields[15] as num?)?.toDouble() ?? 0,
      masteryPoints: Map<String, int>.from(fields[16] as Map? ?? {}),
      benchmarkScores: (fields[17] as Map? ?? {}).map(
        (key, value) => MapEntry(key as String, (value as num).toDouble()),
      ),
      personalRecordMovementIds: List<String>.from(fields[18] as List? ?? []),
      scheduled: fields[19] as bool? ?? false,
      countsForStreak: fields[20] as bool? ?? false,
      committedAt: fields[21] as DateTime?,
      failureMessage: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutModel obj) {
    _writeWorkoutFields(writer, {
      0: obj.id,
      1: obj.date,
      2: obj.durationSeconds,
      3: obj.exercises,
      4: obj.totalXpEarned,
      5: obj.statXpGained,
      6: obj.completed,
      7: obj.notes,
      8: obj.averageFormQuality,
      9: obj.bossDamageDealt,
      10: obj.createdAt,
      11: obj.planId,
      12: obj.plannedDayId,
      13: obj.eventId,
      14: obj.processingStateIndex,
      15: obj.completionRate,
      16: obj.masteryPoints,
      17: obj.benchmarkScores,
      18: obj.personalRecordMovementIds,
      19: obj.scheduled,
      20: obj.countsForStreak,
      21: obj.committedAt,
      22: obj.failureMessage,
    });
  }
}

class ExerciseRecordAdapter extends TypeAdapter<ExerciseRecord> {
  @override
  final int typeId = HiveTypeIds.exerciseRecord;

  @override
  ExerciseRecord read(BinaryReader reader) {
    final fields = _readWorkoutFields(reader);
    return ExerciseRecord(
      id: fields[0] as String,
      exerciseTypeIndex: fields[1] as int,
      sets: fields[2] as int? ?? 1,
      reps: fields[3] as int? ?? 0,
      weight: (fields[4] as num?)?.toDouble() ?? 0,
      durationSeconds: fields[5] as int? ?? 0,
      formQuality: (fields[6] as num?)?.toDouble() ?? 0.8,
      xpEarned: fields[7] as int? ?? 0,
      distanceMeters: (fields[8] as num?)?.toDouble() ?? 0,
      caloriesBurned: fields[9] as int? ?? 0,
      orderIndex: fields[10] as int? ?? 0,
      movementId: fields[11] as String?,
      displayName: fields[12] as String?,
      trackingMetricIndex: fields[13] as int? ?? 0,
      variations: (fields[14] as List?)?.cast<VariationRecord>() ?? [],
      masteryEarned: fields[15] as int? ?? 0,
      isPersonalRecord: fields[16] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseRecord obj) {
    _writeWorkoutFields(writer, {
      0: obj.id,
      1: obj.exerciseTypeIndex,
      2: obj.sets,
      3: obj.reps,
      4: obj.weight,
      5: obj.durationSeconds,
      6: obj.formQuality,
      7: obj.xpEarned,
      8: obj.distanceMeters,
      9: obj.caloriesBurned,
      10: obj.orderIndex,
      11: obj.movementId,
      12: obj.displayName,
      13: obj.trackingMetricIndex,
      14: obj.variations,
      15: obj.masteryEarned,
      16: obj.isPersonalRecord,
    });
  }
}

class VariationRecordAdapter extends TypeAdapter<VariationRecord> {
  @override
  final int typeId = HiveTypeIds.variationRecord;

  @override
  VariationRecord read(BinaryReader reader) {
    final fields = _readWorkoutFields(reader);
    return VariationRecord(
      id: fields[0] as String,
      name: fields[1] as String,
      difficultyMultiplier: (fields[2] as num?)?.toDouble() ?? 1,
      sets: (fields[3] as List?)?.cast<WorkoutSetRecord>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, VariationRecord obj) {
    _writeWorkoutFields(writer, {
      0: obj.id,
      1: obj.name,
      2: obj.difficultyMultiplier,
      3: obj.sets,
    });
  }
}

class WorkoutSetRecordAdapter extends TypeAdapter<WorkoutSetRecord> {
  @override
  final int typeId = HiveTypeIds.workoutSetRecord;

  @override
  WorkoutSetRecord read(BinaryReader reader) {
    final fields = _readWorkoutFields(reader);
    return WorkoutSetRecord(
      id: fields[0] as String,
      reps: fields[1] as int? ?? 0,
      durationSeconds: fields[2] as int? ?? 0,
      distanceMeters: (fields[3] as num?)?.toDouble() ?? 0,
      loadKg: (fields[4] as num?)?.toDouble() ?? 0,
      rpe: fields[5] as int? ?? 7,
      completed: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSetRecord obj) {
    _writeWorkoutFields(writer, {
      0: obj.id,
      1: obj.reps,
      2: obj.durationSeconds,
      3: obj.distanceMeters,
      4: obj.loadKg,
      5: obj.rpe,
      6: obj.completed,
    });
  }
}

Map<int, dynamic> _readWorkoutFields(BinaryReader reader) {
  final fieldCount = reader.readByte();
  return <int, dynamic>{
    for (var index = 0; index < fieldCount; index++)
      reader.readByte(): reader.read(),
  };
}

void _writeWorkoutFields(BinaryWriter writer, Map<int, dynamic> fields) {
  writer.writeByte(fields.length);
  fields.forEach((key, value) {
    writer.writeByte(key);
    writer.write(value);
  });
}
