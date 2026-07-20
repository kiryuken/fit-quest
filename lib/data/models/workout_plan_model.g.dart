// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_plan_model.dart';

class WorkoutPlanModelAdapter extends TypeAdapter<WorkoutPlanModel> {
  @override
  final int typeId = HiveTypeIds.workoutPlanModel;

  @override
  WorkoutPlanModel read(BinaryReader reader) {
    final fields = _readFields(reader);
    return WorkoutPlanModel(
      id: fields[0] as String,
      presetId: fields[1] as String,
      name: fields[2] as String,
      days: (fields[3] as List).cast<PlannedDayModel>(),
      createdAt: fields[4] as DateTime,
      updatedAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutPlanModel obj) {
    _writeFields(writer, {
      0: obj.id,
      1: obj.presetId,
      2: obj.name,
      3: obj.days,
      4: obj.createdAt,
      5: obj.updatedAt,
    });
  }
}

class PlannedDayModelAdapter extends TypeAdapter<PlannedDayModel> {
  @override
  final int typeId = HiveTypeIds.plannedDayModel;

  @override
  PlannedDayModel read(BinaryReader reader) {
    final fields = _readFields(reader);
    return PlannedDayModel(
      id: fields[0] as String,
      weekday: fields[1] as int,
      label: fields[2] as String,
      dayTypeIndex: fields[3] as int,
      isOptional: fields[4] as bool? ?? false,
      exercises: (fields[5] as List?)?.cast<PlannedExerciseModel>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, PlannedDayModel obj) {
    _writeFields(writer, {
      0: obj.id,
      1: obj.weekday,
      2: obj.label,
      3: obj.dayTypeIndex,
      4: obj.isOptional,
      5: obj.exercises,
    });
  }
}

class PlannedExerciseModelAdapter extends TypeAdapter<PlannedExerciseModel> {
  @override
  final int typeId = HiveTypeIds.plannedExerciseModel;

  @override
  PlannedExerciseModel read(BinaryReader reader) {
    final fields = _readFields(reader);
    return PlannedExerciseModel(
      id: fields[0] as String,
      exerciseTypeIndex: fields[1] as int,
      movementId: fields[2] as String,
      name: fields[3] as String,
      trackingMetricIndex: fields[4] as int,
      variations: (fields[5] as List).cast<VariationPlanModel>(),
      isOptional: fields[6] as bool? ?? false,
    );
  }

  @override
  void write(BinaryWriter writer, PlannedExerciseModel obj) {
    _writeFields(writer, {
      0: obj.id,
      1: obj.exerciseTypeIndex,
      2: obj.movementId,
      3: obj.name,
      4: obj.trackingMetricIndex,
      5: obj.variations,
      6: obj.isOptional,
    });
  }
}

class VariationPlanModelAdapter extends TypeAdapter<VariationPlanModel> {
  @override
  final int typeId = HiveTypeIds.variationPlanModel;

  @override
  VariationPlanModel read(BinaryReader reader) {
    final fields = _readFields(reader);
    return VariationPlanModel(
      id: fields[0] as String,
      name: fields[1] as String,
      targetSets: fields[2] as int,
      targetValue: fields[3] as int,
      targetLoadKg: (fields[4] as num?)?.toDouble() ?? 0,
      difficultyMultiplier: (fields[5] as num?)?.toDouble() ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, VariationPlanModel obj) {
    _writeFields(writer, {
      0: obj.id,
      1: obj.name,
      2: obj.targetSets,
      3: obj.targetValue,
      4: obj.targetLoadKg,
      5: obj.difficultyMultiplier,
    });
  }
}

Map<int, dynamic> _readFields(BinaryReader reader) {
  final fieldCount = reader.readByte();
  return <int, dynamic>{
    for (var index = 0; index < fieldCount; index++)
      reader.readByte(): reader.read(),
  };
}

void _writeFields(BinaryWriter writer, Map<int, dynamic> fields) {
  writer.writeByte(fields.length);
  fields.forEach((key, value) {
    writer.writeByte(key);
    writer.write(value);
  });
}
