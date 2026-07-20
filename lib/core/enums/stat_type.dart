enum StatType {
  strength('STR', 'Strength', 0xFFEF5350),
  agility('AGI', 'Agility', 0xFF42A5F5),
  vitality('VIT', 'Vitality', 0xFF2AFC98),
  senses('SEN', 'Senses', 0xFFFDD835),
  intelligence('INT', 'Intelligence', 0xFF673AB7);

  final String shortName;
  final String displayName;
  final int colorValue;

  const StatType(this.shortName, this.displayName, this.colorValue);
}
