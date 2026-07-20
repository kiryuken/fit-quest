import 'stat_type.dart';

enum ExerciseType {
  // Strength
  pushUp('Push Up', {StatType.strength: 1.0, StatType.vitality: 0.3}),
  pullUp('Pull Up', {StatType.strength: 1.2, StatType.senses: 0.2}),
  shoulderRaise('Shoulder Raise', {
    StatType.strength: 0.8,
    StatType.senses: 0.2,
  }),
  bicepCurl('Bicep Curl', {
    StatType.strength: 0.9,
    StatType.senses: 0.2,
  }),
  squat('Squat', {
    StatType.strength: 0.8,
    StatType.vitality: 0.8,
  }),
  calfRaise('Calf Raise', {
    StatType.strength: 0.5,
    StatType.vitality: 0.4,
  }),
  benchPress('Bench Press', {
    StatType.strength: 1.5,
    StatType.vitality: 0.2,
  }),

  // Agility
  jumpingJacks('Jumping Jacks', {
    StatType.agility: 0.8,
    StatType.vitality: 0.4,
  }),
  highKnees('High Knees', {
    StatType.agility: 1.0,
    StatType.vitality: 0.3,
  }),
  burpees('Burpees', {
    StatType.agility: 1.2,
    StatType.strength: 0.3,
    StatType.vitality: 0.5,
  }),

  // Cardio / Vitality
  running('Running', {StatType.vitality: 1.5}),
  cycling('Cycling', {StatType.vitality: 1.0, StatType.strength: 0.2}),
  jumpRope('Jump Rope', {
    StatType.agility: 0.8,
    StatType.vitality: 0.6,
    StatType.senses: 0.3,
  }),

  // Core / Senses
  hangingCore('Hanging Core', {
    StatType.vitality: 0.8,
    StatType.strength: 0.5,
  }),
  plank('Plank', {StatType.vitality: 1.3}),
  sitUp('Sit Up', {StatType.vitality: 0.6, StatType.strength: 0.3}),
  yoga('Yoga', {
    StatType.senses: 1.0,
    StatType.agility: 0.4,
    StatType.vitality: 0.3,
  }),

  // Mixed / Compound
  deadlift('Deadlift', {
    StatType.strength: 1.3,
    StatType.vitality: 0.9,
  }),
  cleanAndPress('Clean & Press', {
    StatType.strength: 1.4,
    StatType.agility: 0.3,
    StatType.vitality: 0.4,
  }),
  lunges('Lunges', {
    StatType.agility: 0.7,
    StatType.strength: 0.5,
    StatType.vitality: 0.3,
  }),

  // Combat
  boxing('Boxing', {
    StatType.senses: 1.0,
    StatType.agility: 0.4,
    StatType.vitality: 0.3,
  }),
  ;

  final String displayName;
  final Map<StatType, double> statWeights;

  const ExerciseType(this.displayName, this.statWeights);

  double get difficultyMultiplier {
    return switch (this) {
      pushUp => 1.0,
      pullUp => 1.4,
      shoulderRaise => 0.8,
      bicepCurl => 0.9,
      squat => 1.0,
      calfRaise => 0.7,
      benchPress => 1.5,
      jumpingJacks => 0.6,
      highKnees => 0.8,
      burpees => 1.5,
      running => 1.2,
      cycling => 1.0,
      jumpRope => 1.1,
      hangingCore => 1.0,
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
