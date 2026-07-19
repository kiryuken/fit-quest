enum Rarity {
  common('Common', 0xFF818E9E),
  uncommon('Uncommon', 0xFF2AFC98),
  rare('Rare', 0xFF42A5F5),
  epic('Epic', 0xFFEC4899),
  legendary('Legendary', 0xFFFDD835);

  final String displayName;
  final int colorValue;

  const Rarity(this.displayName, this.colorValue);
}
