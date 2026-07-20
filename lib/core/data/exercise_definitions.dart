import '../enums/exercise_type.dart';
import '../enums/exercise_tracking_metric.dart';
import '../enums/stat_type.dart';

/// Exercise metadata. Workouts grant mastery in these focus areas; character
/// base stats remain level-derived.
class ExerciseDefinition {
  final ExerciseType type;
  final String movementId;
  final String name;
  final String icon;
  final Set<StatType> focusStats;
  final String questSlug;
  final ExerciseTrackingMetric trackingMetric;
  final double difficultyMultiplier;

  const ExerciseDefinition({
    required this.type,
    required this.movementId,
    required this.name,
    required this.icon,
    required this.focusStats,
    required this.questSlug,
    this.trackingMetric = ExerciseTrackingMetric.repetitions,
    required this.difficultyMultiplier,
  });

  int questProgressFor(int trackedAmount, {int sets = 1}) {
    final amount = trackedAmount < 0 ? 0 : trackedAmount;
    if (trackingMetric == ExerciseTrackingMetric.distanceMeters) {
      return amount;
    }
    if (trackingMetric == ExerciseTrackingMetric.durationSeconds) {
      return amount * (sets < 1 ? 1 : sets);
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
        movementId: 'push_up',
        name: 'Push Up',
        icon: 'fitness_center',
        focusStats: {StatType.strength},
        questSlug: 'push_up',
        difficultyMultiplier: 1),
    ExerciseDefinition(
        type: ExerciseType.pullUp,
        movementId: 'pull_up',
        name: 'Pull Up',
        icon: 'arrow_upward',
        focusStats: {StatType.strength, StatType.senses},
        questSlug: 'pull_up',
        difficultyMultiplier: 1.4),
    ExerciseDefinition(
        type: ExerciseType.shoulderRaise,
        movementId: 'shoulder_raise',
        name: 'Shoulder Raise',
        icon: 'fitness_center',
        focusStats: {StatType.strength, StatType.senses},
        questSlug: 'shoulder_raise',
        difficultyMultiplier: 0.8),
    ExerciseDefinition(
        type: ExerciseType.hangingCore,
        movementId: 'hanging_core',
        name: 'Hanging Core',
        icon: 'timer',
        focusStats: {StatType.vitality, StatType.strength},
        questSlug: 'hanging_core',
        trackingMetric: ExerciseTrackingMetric.durationSeconds,
        difficultyMultiplier: 1),
    ExerciseDefinition(
        type: ExerciseType.bicepCurl,
        movementId: 'bicep_curl',
        name: 'Bicep Curl',
        icon: 'fitness_center',
        focusStats: {StatType.strength, StatType.senses},
        questSlug: 'bicep_curl',
        difficultyMultiplier: 0.9),
    ExerciseDefinition(
        type: ExerciseType.squat,
        movementId: 'squat',
        name: 'Squat',
        icon: 'accessibility_new',
        focusStats: {StatType.strength, StatType.vitality},
        questSlug: 'squat',
        difficultyMultiplier: 1),
    ExerciseDefinition(
        type: ExerciseType.calfRaise,
        movementId: 'calf_raise',
        name: 'Calf Raise',
        icon: 'height',
        focusStats: {StatType.strength, StatType.vitality},
        questSlug: 'calf_raise',
        difficultyMultiplier: 0.7),
    ExerciseDefinition(
        type: ExerciseType.running,
        movementId: 'running',
        name: 'Running',
        icon: 'directions_run',
        focusStats: {StatType.vitality},
        questSlug: 'running',
        trackingMetric: ExerciseTrackingMetric.distanceMeters,
        difficultyMultiplier: 1.2),
    ExerciseDefinition(
        type: ExerciseType.cycling,
        movementId: 'cycling',
        name: 'Cycling',
        icon: 'directions_bike',
        focusStats: {StatType.vitality},
        questSlug: 'cycling',
        trackingMetric: ExerciseTrackingMetric.durationSeconds,
        difficultyMultiplier: 1),
    ExerciseDefinition(
        type: ExerciseType.jumpRope,
        movementId: 'jump_rope',
        name: 'Jump Rope',
        icon: 'loop',
        focusStats: {StatType.agility, StatType.vitality},
        questSlug: 'jump_rope',
        difficultyMultiplier: 1.1),
    ExerciseDefinition(
        type: ExerciseType.boxing,
        movementId: 'boxing',
        name: 'Boxing',
        icon: 'sports_mma',
        focusStats: {StatType.senses, StatType.agility},
        questSlug: 'boxing',
        difficultyMultiplier: 1.2),
  ];
}
