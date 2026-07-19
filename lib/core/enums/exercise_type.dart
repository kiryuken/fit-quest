import 'stat_type.dart';

enum ExerciseType {
  // Strength
  pushUp('Push Up', {StatType.strength: 1.0, StatType.endurance: 0.3}),
  pullUp('Pull Up', {StatType.strength: 1.2, StatType.dexterity: 0.2}),
  squat('Squat', {
    StatType.strength: 0.8,
    StatType.endurance: 0.5,
    StatType.constitution: 0.3
  }),
  benchPress(
      'Bench Press', {StatType.strength: 1.5, StatType.constitution: 0.2}),

  // Agility
  jumpingJacks(
      'Jumping Jacks', {StatType.agility: 0.8, StatType.endurance: 0.4}),
  highKnees('High Knees', {StatType.agility: 1.0, StatType.endurance: 0.3}),
  burpees('Burpees',
      {StatType.agility: 1.2, StatType.strength: 0.3, StatType.endurance: 0.5}),

  // Cardio / Endurance
  running('Running', {StatType.endurance: 1.2, StatType.constitution: 0.3}),
  cycling('Cycling', {StatType.endurance: 1.0, StatType.strength: 0.2}),
  jumpRope('Jump Rope', {
    StatType.agility: 0.8,
    StatType.endurance: 0.6,
    StatType.dexterity: 0.3
  }),

  // Core / Dexterity
  plank('Plank', {StatType.endurance: 0.5, StatType.constitution: 0.8}),
  sitUp('Sit Up', {StatType.constitution: 0.6, StatType.strength: 0.3}),
  yoga('Yoga', {
    StatType.dexterity: 1.0,
    StatType.agility: 0.4,
    StatType.endurance: 0.3
  }),

  // Mixed / Compound
  deadlift('Deadlift', {
    StatType.strength: 1.3,
    StatType.constitution: 0.6,
    StatType.endurance: 0.3
  }),
  cleanAndPress('Clean & Press',
      {StatType.strength: 1.4, StatType.agility: 0.3, StatType.endurance: 0.4}),
  lunges('Lunges',
      {StatType.agility: 0.7, StatType.strength: 0.5, StatType.endurance: 0.3}),

  // Combat
  boxing('Boxing', {
    StatType.dexterity: 1.0,
    StatType.agility: 0.4,
    StatType.endurance: 0.3
  }),
  ;

  final String displayName;
  final Map<StatType, double> statWeights;

  const ExerciseType(this.displayName, this.statWeights);

  double get difficultyMultiplier {
    return switch (this) {
      pushUp => 1.0,
      pullUp => 1.4,
      squat => 1.0,
      benchPress => 1.5,
      jumpingJacks => 0.6,
      highKnees => 0.8,
      burpees => 1.5,
      running => 1.2,
      cycling => 1.0,
      jumpRope => 1.1,
      plank => 0.7,
      sitUp => 0.8,
      yoga => 0.7,
      deadlift => 1.7,
      cleanAndPress => 1.6,
      lunges => 1.0,
      boxing => 1.2,
    };
  }
}
