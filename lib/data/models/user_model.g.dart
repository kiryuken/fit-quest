// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = HiveTypeIds.userModel;

  @override
  UserModel read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{
      for (var index = 0; index < fieldCount; index++)
        reader.readByte(): reader.read(),
    };
    final updatedAt = fields[19] as DateTime;
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      level: fields[2] as int? ?? 1,
      currentXp: fields[3] as int? ?? 0,
      totalXp: fields[4] as int? ?? 0,
      stats: (fields[5] as Map? ?? {}).map(
        (key, value) => MapEntry(key as int, (value as num).toDouble()),
      ),
      unlockedSkills: List<String>.from(fields[6] as List? ?? []),
      skillLevels: Map<String, int>.from(fields[7] as Map? ?? {}),
      currentHp: fields[8] as int? ?? 155,
      maxHp: fields[9] as int? ?? 155,
      streak: fields[10] as int? ?? 0,
      longestStreak: fields[11] as int? ?? 0,
      streakShields: fields[12] as int? ?? 0,
      lastWorkoutAt: fields[13] as DateTime?,
      title: fields[14] as String? ?? '',
      unlockedTitles: List<String>.from(fields[15] as List? ?? []),
      bossBattlesWon: fields[16] as int? ?? 0,
      totalWorkoutsCompleted: fields[17] as int? ?? 0,
      createdAt: fields[18] as DateTime,
      updatedAt: updatedAt,
      age: fields[20] as int? ?? 18,
      height: (fields[21] as num?)?.toDouble() ?? 170,
      weight: (fields[22] as num?)?.toDouble() ?? 70,
      fitnessLevel: fields[23] as String? ?? 'Beginner',
      preferredFocusIndex: fields[24] as int?,
      masteryXp: Map<String, int>.from(fields[25] as Map? ?? {}),
      workoutXpToday: fields[26] as int? ?? 0,
      questXpToday: fields[27] as int? ?? 0,
      xpBudgetDate: fields[28] as DateTime?,
      processedEventXp: Map<String, int>.from(fields[29] as Map? ?? {}),
      scheduledCompletions: fields[30] as int? ?? 0,
      personalRecordMovementIds: List<String>.from(fields[31] as List? ?? []),
      lastStreakWorkoutAt: fields[32] as DateTime?,
      completedScheduledDates: List<DateTime>.from(fields[33] as List? ?? []),
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
      20: obj.age,
      21: obj.height,
      22: obj.weight,
      23: obj.fitnessLevel,
      24: obj.preferredFocusIndex,
      25: obj.masteryXp,
      26: obj.workoutXpToday,
      27: obj.questXpToday,
      28: obj.xpBudgetDate,
      29: obj.processedEventXp,
      30: obj.scheduledCompletions,
      31: obj.personalRecordMovementIds,
      32: obj.lastStreakWorkoutAt,
      33: obj.completedScheduledDates,
    };
    writer.writeByte(fields.length);
    fields.forEach((key, value) {
      writer.writeByte(key);
      writer.write(value);
    });
  }
}
