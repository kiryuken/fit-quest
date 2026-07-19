enum MartialArt {
  aikido('Aikido', 'Throws, Joint Locks, Redirection'),
  taekwondo('Taekwondo', 'Kicking, Striking, Speed'),
  muayThai('Muay Thai', 'Striking, Clinch, Power'),
  capoeira('Capoeira', 'Acrobatics, Rhythm, Flow'),
  kravMaga('Krav Maga', 'Self-Defense, Efficiency');

  final String displayName;
  final String description;

  const MartialArt(this.displayName, this.description);
}
