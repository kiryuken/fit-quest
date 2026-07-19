enum StatType {
  strength('STR', 'Strength', 0xFFEF5350),
  agility('AGI', 'Agility', 0xFF42A5F5),
  endurance('END', 'Endurance', 0xFF2AFC98),
  dexterity('DEX', 'Dexterity', 0xFFFDD835),
  constitution('CON', 'Constitution', 0xFF2DD4BF),
  intelligence('INT', 'Intelligence', 0xFF673AB7);

  final String shortName;
  final String displayName;
  final int colorValue;

  const StatType(this.shortName, this.displayName, this.colorValue);
}
