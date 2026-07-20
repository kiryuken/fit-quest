// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'boss_battle_model.dart';

class BossBattleModelAdapter extends TypeAdapter<BossBattleModel> {
  @override
  final int typeId = 6;

  @override
  BossBattleModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return BossBattleModel(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      level: fields[3] as int? ?? 1,
      hp: fields[4] as int? ?? 100,
      currentDamageDone: fields[5] as int? ?? 0,
      statThresholds: Map<int, int>.from(fields[6] as Map? ?? {}),
      xpReward: fields[7] as int? ?? 100,
      statRewards: Map<int, int>.from(fields[8] as Map? ?? {}),
      skillRewardId: fields[9] as String?,
      iconAsset: fields[10] as String? ?? '',
      requiredWorkouts: fields[11] as int? ?? 0,
      isDefeated: fields[12] as bool? ?? false,
      tierIndex: fields[13] as int? ?? 0,
      difficulty: fields[14] as int? ?? 1,
    );
  }

  @override
  void write(BinaryWriter writer, BossBattleModel obj) {
    writer.writeByte(15);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.name);
    writer.writeByte(2);
    writer.write(obj.description);
    writer.writeByte(3);
    writer.write(obj.level);
    writer.writeByte(4);
    writer.write(obj.hp);
    writer.writeByte(5);
    writer.write(obj.currentDamageDone);
    writer.writeByte(6);
    writer.write(obj.statThresholds);
    writer.writeByte(7);
    writer.write(obj.xpReward);
    writer.writeByte(8);
    writer.write(obj.statRewards);
    writer.writeByte(9);
    writer.write(obj.skillRewardId);
    writer.writeByte(10);
    writer.write(obj.iconAsset);
    writer.writeByte(11);
    writer.write(obj.requiredWorkouts);
    writer.writeByte(12);
    writer.write(obj.isDefeated);
    writer.writeByte(13);
    writer.write(obj.tierIndex);
    writer.writeByte(14);
    writer.write(obj.difficulty);
  }
}
