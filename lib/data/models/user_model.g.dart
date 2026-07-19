// GENERATED CODE - DO NOT MODIFY BY HAND
// This is a stub adapter. Run build_runner to generate.

part of 'user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      final value = reader.read();
      fields[key] = value;
    }
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      level: fields[2] as int? ?? 1,
      currentXp: fields[3] as int? ?? 0,
      totalXp: fields[4] as int? ?? 0,
      stats: Map<int, int>.from(fields[5] as Map? ?? {}),
      unlockedSkills: List<String>.from(fields[6] as List? ?? []),
      skillLevels: Map<String, int>.from(fields[7] as Map? ?? {}),
      currentHp: fields[8] as int? ?? 100,
      maxHp: fields[9] as int? ?? 100,
      streak: fields[10] as int? ?? 0,
      longestStreak: fields[11] as int? ?? 0,
      streakShields: fields[12] as int? ?? 0,
      lastWorkoutAt: fields[13] as DateTime,
      title: fields[14] as String? ?? '',
      unlockedTitles: List<String>.from(fields[15] as List? ?? []),
      bossBattlesWon: fields[16] as int? ?? 0,
      totalWorkoutsCompleted: fields[17] as int? ?? 0,
      createdAt: fields[18] as DateTime,
      updatedAt: fields[19] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    final fields = <int, dynamic>{
      0: obj.id,
      1: obj.name,
      2: obj.level,
      3: obj.currentXp,
      4: obj.totalXp,
      5: obj.stats,
      6: obj.unlockedSkills,
      7: obj.skillLevels,
      8: obj.currentHp,
      9: obj.maxHp,
      10: obj.streak,
      11: obj.longestStreak,
      12: obj.streakShields,
      13: obj.lastWorkoutAt,
      14: obj.title,
      15: obj.unlockedTitles,
      16: obj.bossBattlesWon,
      17: obj.totalWorkoutsCompleted,
      18: obj.createdAt,
      19: obj.updatedAt,
    };
    writer.writeByte(fields.length);
    fields.forEach((key, value) {
      writer.writeByte(key);
      writer.write(value);
    });
  }
}
