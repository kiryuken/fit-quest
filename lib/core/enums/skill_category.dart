enum SkillCategory {
  striking('Striking'),
  throwing('Throwing'),
  jointLock('Joint Lock'),
  grappling('Grappling'),
  kicking('Kicking'),
  acrobatics('Acrobatics'),
  dodge('Dodge'),
  selfDefense('Self Defense'),
  form('Form/Poomsae'),
  weapons('Weapons');

  final String displayName;

  const SkillCategory(this.displayName);
}
