import 'package:flutter/material.dart';

/// FitQuest's Aurora Glass color system.
///
/// The palette is normalized from the experiments in `design-ctx`: the
/// near-black aurora canvas, indigo/teal/pink light fields, white glass layers,
/// and the semantic colors used by the reference app.
class AppColors {
  AppColors._();

  // Canvas and solid fallbacks.
  static const Color background = Color(0xFF05010F);
  static const Color surface = Color(0xFF1E1B4B);
  static const Color elevated = Color(0xFF1E1B4B);
  static const Color card = Color(0x1AFFFFFF);

  // Aurora spectrum.
  static const Color accent = Color(0xFF6366F1);
  static const Color accentActive = Color(0xFF3949AB);
  static const Color turquoise = Color(0xFF2DD4BF);
  static const Color pink = Color(0xFFEC4899);
  static const Color violet = Color(0xFF673AB7);

  // Text hierarchy: white at the opacity levels used by the references.
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xCCFFFFFF);
  static const Color textDimmed = Color(0x99FFFFFF);
  static const Color textInverse = Color(0xFF05010F);

  // Semantic colors from the glass app experiment.
  static const Color gold = Color(0xFFFDD835);
  static const Color goldActive = Color(0xFFFFA000);
  static const Color danger = Color(0xFFEF5350);
  static const Color success = Color(0xFF2AFC98);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF42A5F5);

  // Attribute spectrum.
  static const Color strengthColor = danger;
  static const Color agilityColor = info;
  static const Color vitalityColor = success;
  static const Color sensesColor = gold;
  static const Color intelligenceColor = violet;

  // Glass layers.
  static const Color glassBg = Color(0x1AFFFFFF);
  static const Color glassStrong = Color(0x26FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassHighlight = Color(0x70FFFFFF);
  static const Color divider = Color(0x20FFFFFF);
  static const Color scrim = Color(0x9905010F);

  // Progress.
  static const Color xpBar = accent;
  static const Color xpBarEnd = pink;
  static const Color xpBarBg = Color(0x661E1B4B);

  // Rarity ladder.
  static const Color common = Color(0x99818E9E);
  static const Color uncommon = success;
  static const Color rare = info;
  static const Color epic = pink;
  static const Color legendary = gold;

  static const LinearGradient auroraGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, violet, pink],
  );

  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, turquoise],
  );

  static const LinearGradient rewardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gold, goldActive],
  );

  static Color forStat(String statName) {
    return switch (statName) {
      'strength' => strengthColor,
      'agility' => agilityColor,
      'vitality' => vitalityColor,
      'senses' => sensesColor,
      'intelligence' => intelligenceColor,
      _ => textDimmed,
    };
  }

  static Color forRarity(String rarityName) {
    return switch (rarityName) {
      'common' => common,
      'uncommon' => uncommon,
      'rare' => rare,
      'epic' => epic,
      'legendary' => legendary,
      _ => textDimmed,
    };
  }
}
