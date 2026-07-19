import '../enums/exercise_type.dart';
import '../enums/stat_type.dart';

enum ExerciseTrackingMetric {
  repetitions(
    displayLabel: 'Repetitions',
    shortLabel: 'REPS',
    inputStep: 5,
  ),
  distanceMeters(
    displayLabel: 'Distance',
    shortLabel: 'METERS',
    inputStep: 100,
  );

  final String displayLabel;
  final String shortLabel;
  final int inputStep;

  const ExerciseTrackingMetric({
    required this.displayLabel,
    required this.shortLabel,
    required this.inputStep,
  });
}

/// Predefined exercises with stat rewards and EXP.
class ExerciseDefinition {
  final ExerciseType type;
  final String name;
  final String icon;
  final Map<StatType, int> statGains;
  final int expReward;
  final String questSlug;
  final ExerciseTrackingMetric trackingMetric;

  const ExerciseDefinition({
    required this.type,
    required this.name,
    required this.icon,
    required this.statGains,
    required this.expReward,
    required this.questSlug,
    this.trackingMetric = ExerciseTrackingMetric.repetitions,
  });

  int questProgressFor(int trackedAmount, {int sets = 1}) {
    final amount = trackedAmount < 0 ? 0 : trackedAmount;
    if (trackingMetric == ExerciseTrackingMetric.distanceMeters) {
      return amount;
    }
    return amount * (sets < 1 ? 1 : sets);
  }

  int repetitionsFor(int trackedAmount) =>
      trackingMetric == ExerciseTrackingMetric.repetitions
          ? questProgressFor(trackedAmount)
          : 0;

  double distanceMetersFor(int trackedAmount) =>
      trackingMetric == ExerciseTrackingMetric.distanceMeters
          ? questProgressFor(trackedAmount).toDouble()
          : 0;

  static const List<ExerciseDefinition> all = [
    ExerciseDefinition(
        type: ExerciseType.pushUp,
        name: 'Push Up',
        icon: 'fitness_center',
        statGains: {StatType.strength: 2},
        expReward: 20,
        questSlug: 'pushup'),
    ExerciseDefinition(
        type: ExerciseType.pullUp,
        name: 'Pull Up',
        icon: 'arrow_upward',
        statGains: {StatType.strength: 3},
        expReward: 30,
        questSlug: 'pullup'),
    ExerciseDefinition(
        type: ExerciseType.running,
        name: 'Running',
        icon: 'directions_run',
        statGains: {StatType.endurance: 3},
        expReward: 35,
        questSlug: 'running',
        trackingMetric: ExerciseTrackingMetric.distanceMeters),
    ExerciseDefinition(
        type: ExerciseType.jumpRope,
        name: 'Jump Rope',
        icon: 'loop',
        statGains: {StatType.agility: 2},
        expReward: 25,
        questSlug: 'jump_rope'),
    ExerciseDefinition(
        type: ExerciseType.boxing,
        name: 'Boxing',
        icon: 'sports_mma',
        statGains: {StatType.dexterity: 2},
        expReward: 30,
        questSlug: 'boxing'),
  ];
}
