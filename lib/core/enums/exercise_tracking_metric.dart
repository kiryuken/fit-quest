enum ExerciseTrackingMetric {
  repetitions(
    displayLabel: 'Repetitions',
    shortLabel: 'REPS',
    inputStep: 1,
  ),
  durationSeconds(
    displayLabel: 'Duration',
    shortLabel: 'SEC',
    inputStep: 10,
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

  bool isValid({
    required int reps,
    required int durationSeconds,
    required double distanceMeters,
  }) {
    return switch (this) {
      ExerciseTrackingMetric.repetitions => reps >= 1,
      ExerciseTrackingMetric.durationSeconds => durationSeconds >= 10,
      ExerciseTrackingMetric.distanceMeters => distanceMeters >= 1,
    };
  }
}
