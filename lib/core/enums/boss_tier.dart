enum BossTier {
  normal('Normal', 0xFF42A5F5),
  elite('Elite', 0xFFEC4899),
  legendary('Legendary', 0xFFFDD835);

  final String displayName;
  final int colorValue;

  const BossTier(this.displayName, this.colorValue);
}
