import 'package:hive/hive.dart';
import '../../core/constants/hive_type_ids.dart';
import '../../core/enums/boss_tier.dart';

part 'boss_battle_model.g.dart';

@HiveType(typeId: HiveTypeIds.bossBattleModel)
class BossBattleModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int level;

  @HiveField(4)
  final int hp;

  @HiveField(5)
  final int currentDamageDone;

  @HiveField(6)
  final Map<int, int> statThresholds; // StatType index -> required value

  @HiveField(7)
  final int xpReward;

  @HiveField(8)
  final Map<int, int> statRewards; // StatType index -> bonus XP

  @HiveField(9)
  final String? skillRewardId;

  @HiveField(10)
  final String iconAsset;

  @HiveField(11)
  final int requiredWorkouts;

  @HiveField(12)
  final bool isDefeated;

  @HiveField(13)
  final int tierIndex; // BossTier enum index

  @HiveField(14)
  final int difficulty;

  BossBattleModel({
    required this.id,
    required this.name,
    required this.description,
    this.level = 1,
    this.hp = 100,
    this.currentDamageDone = 0,
    this.statThresholds = const {},
    this.xpReward = 100,
    this.statRewards = const {},
    this.skillRewardId,
    this.iconAsset = '',
    this.requiredWorkouts = 0,
    this.isDefeated = false,
    this.tierIndex = 0,
    this.difficulty = 1,
  });

  BossTier get tier => BossTier.values[tierIndex];

  BossBattleModel copyWith({
    String? id,
    String? name,
    String? description,
    int? level,
    int? hp,
    int? currentDamageDone,
    Map<int, int>? statThresholds,
    int? xpReward,
    Map<int, int>? statRewards,
    String? skillRewardId,
    String? iconAsset,
    int? requiredWorkouts,
    bool? isDefeated,
    int? tierIndex,
    int? difficulty,
  }) {
    return BossBattleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      level: level ?? this.level,
      hp: hp ?? this.hp,
      currentDamageDone: currentDamageDone ?? this.currentDamageDone,
      statThresholds: statThresholds ?? this.statThresholds,
      xpReward: xpReward ?? this.xpReward,
      statRewards: statRewards ?? this.statRewards,
      skillRewardId: skillRewardId ?? this.skillRewardId,
      iconAsset: iconAsset ?? this.iconAsset,
      requiredWorkouts: requiredWorkouts ?? this.requiredWorkouts,
      isDefeated: isDefeated ?? this.isDefeated,
      tierIndex: tierIndex ?? this.tierIndex,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
