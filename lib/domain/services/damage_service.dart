import 'dart:math';
import '../../core/enums/stat_type.dart';

class DamageService {
  /// Core damage calculation for a skill-based attack
  static int calculateDamage({
    required double baseDamage,
    required double damageMultiplier,
    required Map<StatType, int> playerStats,
    required double formQuality,
    int comboCount = 0,
    bool isStatCheckPassed = false,
    bool isCritical = false,
    int playerLevel = 1,
    int bossLevel = 1,
  }) {
    // 1. Base damage
    double damage = baseDamage;

    // 2. Stat scaling
    final strBonus = (playerStats[StatType.strength] ?? 0) * 0.02;
    final agiBonus = (playerStats[StatType.agility] ?? 0) * 0.015;
    final dexBonus = (playerStats[StatType.dexterity] ?? 0) * 0.01;
    final totalStatMultiplier = 1.0 + strBonus + agiBonus + dexBonus;
    damage *= totalStatMultiplier;

    // 3. Level multiplier from skill
    damage *= damageMultiplier;

    // 4. Form quality bonus
    final formMultiplier = 0.75 + (formQuality * 0.5);
    damage *= formMultiplier;

    // 5. Combo/streak bonus
    final comboMultiplier = 1.0 + (comboCount * 0.05).clamp(0.0, 1.0);
    damage *= comboMultiplier;

    // 6. Stat check pass bonus
    if (isStatCheckPassed) {
      damage *= 1.5;
    }

    // 7. Critical hit (10% base chance, +1% per DEX)
    if (isCritical) {
      damage *= 2.5;
    }

    // 8. Level difference resistance
    final levelDiff = playerLevel - bossLevel;
    final resistanceFactor = (1.0 + (levelDiff * 0.02)).clamp(0.3, 3.0);
    damage *= resistanceFactor;

    return damage.round();
  }

  /// Check if a stat check is passed
  static bool passStatCheck(StatType stat, int playerValue, int requiredValue) {
    return playerValue >= requiredValue;
  }

  /// Random critical hit check
  static bool rollCriticalHit(int dexterity) {
    final critChance = 0.10 + (dexterity * 0.01); // 10% + 1% per DEX
    return Random().nextDouble() < critChance.clamp(0.05, 0.50);
  }

  /// Calculate boss HP based on level and tier
  static int calculateBossHp(int level, int difficulty) {
    return 50 + (level * 30) + (difficulty * 50);
  }

  /// Daily damage cap based on player level
  static int dailyDamageCap(int playerLevel) {
    return 50 + (playerLevel * 10);
  }
}
