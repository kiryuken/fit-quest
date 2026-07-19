import 'package:hive/hive.dart';
import '../../core/constants/hive_type_ids.dart';
import '../../core/enums/martial_art.dart';
import '../../core/enums/skill_category.dart';

part 'skill_model.g.dart';

@HiveType(typeId: HiveTypeIds.skillModel)
class SkillModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int martialArtIndex; // MartialArt enum index

  @HiveField(4)
  final int categoryIndex; // SkillCategory enum index

  @HiveField(5)
  final int maxLevel;

  @HiveField(6)
  final List<String> prerequisites;

  @HiveField(7)
  final List<SkillLevelData> levels;

  @HiveField(8)
  final String iconAsset;

  @HiveField(9)
  final String? requiredEquipment;

  SkillModel({
    required this.id,
    required this.name,
    required this.description,
    required this.martialArtIndex,
    required this.categoryIndex,
    this.maxLevel = 5,
    this.prerequisites = const [],
    this.levels = const [],
    this.iconAsset = '',
    this.requiredEquipment,
  });

  MartialArt get martialArt => MartialArt.values[martialArtIndex];
  SkillCategory get category => SkillCategory.values[categoryIndex];

  SkillLevelData? levelData(int level) {
    if (level < 1 || level > levels.length) return null;
    return levels[level - 1];
  }
}

@HiveType(typeId: HiveTypeIds.skillLevelData)
class SkillLevelData extends HiveObject {
  @HiveField(0)
  final int level;

  @HiveField(1)
  final int xpRequired;

  @HiveField(2)
  final double damageMultiplier;

  @HiveField(3)
  final Map<int, int> statRequirements; // StatType index -> min value

  @HiveField(4)
  final List<ExerciseRequirement> exerciseRequirements;

  @HiveField(5)
  final String? unlockEffect;

  @HiveField(6)
  final int baseDamage;

  SkillLevelData({
    required this.level,
    required this.xpRequired,
    required this.damageMultiplier,
    this.statRequirements = const {},
    this.exerciseRequirements = const [],
    this.unlockEffect,
    this.baseDamage = 10,
  });
}

@HiveType(typeId: HiveTypeIds.exerciseRequirement)
class ExerciseRequirement extends HiveObject {
  @HiveField(0)
  final int exerciseTypeIndex;

  @HiveField(1)
  final int minimumSets;

  @HiveField(2)
  final int minimumReps;

  @HiveField(3)
  final int totalRequired;

  @HiveField(4)
  final double minimumFormQuality;

  ExerciseRequirement({
    required this.exerciseTypeIndex,
    this.minimumSets = 1,
    this.minimumReps = 1,
    this.totalRequired = 10,
    this.minimumFormQuality = 0.6,
  });
}
