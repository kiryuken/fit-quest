// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'skill_model.dart';

class SkillModelAdapter extends TypeAdapter<SkillModel> {
  @override
  final int typeId = 3;

  @override
  SkillModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SkillModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      martialArtIndex: fields[3] as int,
      categoryIndex: fields[4] as int,
      maxLevel: fields[5] as int? ?? 5,
      prerequisites: List<String>.from(fields[6] as List? ?? []),
      levels: (fields[7] as List?)?.cast<SkillLevelData>() ?? [],
      iconAsset: fields[8] as String? ?? '',
      requiredEquipment: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SkillModel obj) {
    writer.writeByte(10);
    writer.writeByte(0); writer.write(obj.id);
    writer.writeByte(1); writer.write(obj.name);
    writer.writeByte(2); writer.write(obj.description);
    writer.writeByte(3); writer.write(obj.martialArtIndex);
    writer.writeByte(4); writer.write(obj.categoryIndex);
    writer.writeByte(5); writer.write(obj.maxLevel);
    writer.writeByte(6); writer.write(obj.prerequisites);
    writer.writeByte(7); writer.write(obj.levels);
    writer.writeByte(8); writer.write(obj.iconAsset);
    writer.writeByte(9); writer.write(obj.requiredEquipment);
  }
}

class SkillLevelDataAdapter extends TypeAdapter<SkillLevelData> {
  @override
  final int typeId = 4;

  @override
  SkillLevelData read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return SkillLevelData(
      level: fields[0] as int,
      xpRequired: fields[1] as int,
      damageMultiplier: fields[2] as double,
      statRequirements: Map<int, int>.from(fields[3] as Map? ?? {}),
      exerciseRequirements: (fields[4] as List?)?.cast<ExerciseRequirement>() ?? [],
      unlockEffect: fields[5] as String?,
      baseDamage: fields[6] as int? ?? 10,
    );
  }

  @override
  void write(BinaryWriter writer, SkillLevelData obj) {
    writer.writeByte(7);
    writer.writeByte(0); writer.write(obj.level);
    writer.writeByte(1); writer.write(obj.xpRequired);
    writer.writeByte(2); writer.write(obj.damageMultiplier);
    writer.writeByte(3); writer.write(obj.statRequirements);
    writer.writeByte(4); writer.write(obj.exerciseRequirements);
    writer.writeByte(5); writer.write(obj.unlockEffect);
    writer.writeByte(6); writer.write(obj.baseDamage);
  }
}

class ExerciseRequirementAdapter extends TypeAdapter<ExerciseRequirement> {
  @override
  final int typeId = 5;

  @override
  ExerciseRequirement read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return ExerciseRequirement(
      exerciseTypeIndex: fields[0] as int,
      minimumSets: fields[1] as int? ?? 1,
      minimumReps: fields[2] as int? ?? 1,
      totalRequired: fields[3] as int? ?? 10,
      minimumFormQuality: fields[4] as double? ?? 0.6,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseRequirement obj) {
    writer.writeByte(5);
    writer.writeByte(0); writer.write(obj.exerciseTypeIndex);
    writer.writeByte(1); writer.write(obj.minimumSets);
    writer.writeByte(2); writer.write(obj.minimumReps);
    writer.writeByte(3); writer.write(obj.totalRequired);
    writer.writeByte(4); writer.write(obj.minimumFormQuality);
  }
}
