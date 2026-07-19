// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_model.dart';

class WorkoutModelAdapter extends TypeAdapter<WorkoutModel> {
  @override
  final int typeId = 1;

  @override
  WorkoutModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return WorkoutModel(
      id: fields[0] as String,
      date: fields[1] as DateTime,
      durationSeconds: fields[2] as int? ?? 0,
      exercises: (fields[3] as List?)?.cast<ExerciseRecord>() ?? [],
      totalXpEarned: fields[4] as int? ?? 0,
      statXpGained: Map<int, int>.from(fields[5] as Map? ?? {}),
      completed: fields[6] as bool? ?? false,
      notes: fields[7] as String?,
      averageFormQuality: fields[8] as double? ?? 0.0,
      bossDamageDealt: fields[9] as int? ?? 0,
      createdAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutModel obj) {
    writer.writeByte(11);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.date);
    writer.writeByte(2); writer.write(obj.durationSeconds);
    writer.writeByte(3); writer.write(obj.exercises);
    writer.writeByte(4); writer.write(obj.totalXpEarned);
    writer.writeByte(5); writer.write(obj.statXpGained);
    writer.writeByte(6); writer.write(obj.completed);
    writer.writeByte(7); writer.write(obj.notes);
    writer.writeByte(8); writer.write(obj.averageFormQuality);
    writer.writeByte(9); writer.write(obj.bossDamageDealt);
    writer.writeByte(10); writer.write(obj.createdAt);
  }
}

class ExerciseRecordAdapter extends TypeAdapter<ExerciseRecord> {
  @override
  final int typeId = 2;

  @override
  ExerciseRecord read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ExerciseRecord(
      id: fields[0] as String,
      exerciseTypeIndex: fields[1] as int,
      sets: fields[2] as int? ?? 1,
      reps: fields[3] as int? ?? 0,
      weight: fields[4] as double? ?? 0.0,
      durationSeconds: fields[5] as int? ?? 0,
      formQuality: fields[6] as double? ?? 0.7,
      xpEarned: fields[7] as int? ?? 0,
      distanceMeters: fields[8] as double? ?? 0.0,
      caloriesBurned: fields[9] as int? ?? 0,
      orderIndex: fields[10] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseRecord obj) {
    writer.writeByte(11);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.exerciseTypeIndex);
    writer.writeByte(2); writer.write(obj.sets);
    writer.writeByte(3); writer.write(obj.reps);
    writer.writeByte(4); writer.write(obj.weight);
    writer.writeByte(5); writer.write(obj.durationSeconds);
    writer.writeByte(6); writer.write(obj.formQuality);
    writer.writeByte(7); writer.write(obj.xpEarned);
    writer.writeByte(8); writer.write(obj.distanceMeters);
    writer.writeByte(9); writer.write(obj.caloriesBurned);
    writer.writeByte(10); writer.write(obj.orderIndex);
  }
}
