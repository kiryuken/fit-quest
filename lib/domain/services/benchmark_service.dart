import '../../data/models/workout_model.dart';
import '../../core/enums/exercise_tracking_metric.dart';

/// Comparable performance scores used only for personal-record milestones.
class BenchmarkService {
  BenchmarkService._();

  static const double minimumImprovement = 0.05;

  static double score(ExerciseRecord exercise) {
    final sets = exercise.variations
        .expand((variation) => variation.sets.map(
              (set) => (set: set, difficulty: variation.difficultyMultiplier),
            ))
        .where((entry) => entry.set.isValid(exercise.trackingMetric))
        .toList();
    if (sets.isEmpty) return 0;

    return switch (exercise.trackingMetric) {
      ExerciseTrackingMetric.repetitions => sets.fold<double>(
          0,
          (total, entry) =>
              total +
              (entry.set.reps *
                  entry.difficulty *
                  (1 + (entry.set.loadKg / 10))),
        ),
      ExerciseTrackingMetric.durationSeconds => sets.fold<double>(
          0,
          (best, entry) {
            final score = entry.set.durationSeconds * entry.difficulty;
            return score > best ? score : best;
          },
        ),
      ExerciseTrackingMetric.distanceMeters => sets.fold<double>(
          0,
          (total, entry) {
            if (entry.set.durationSeconds <= 0) return total;
            return total + (entry.set.distanceMeters * entry.difficulty);
          },
        ),
    };
  }

  static bool isPersonalRecord({
    required double score,
    required double previousBest,
  }) {
    if (score <= 0 || previousBest <= 0) return false;
    return score >= previousBest * (1 + minimumImprovement);
  }
}
