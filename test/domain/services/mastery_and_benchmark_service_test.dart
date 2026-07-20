import 'package:fitquest_rpg/core/enums/exercise_tracking_metric.dart';
import 'package:fitquest_rpg/core/enums/exercise_type.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/domain/services/benchmark_service.dart';
import 'package:fitquest_rpg/domain/services/mastery_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MasteryService', () {
    test('uses valid sets, difficulty, and a PR multiplier', () {
      expect(
        MasteryService.pointsForSession(
          validSets: 16,
          difficultyMultiplier: 1.2,
          isPersonalRecord: false,
        ),
        24,
      );
      expect(
        MasteryService.pointsForSession(
          validSets: 16,
          difficultyMultiplier: 1.2,
          isPersonalRecord: true,
        ),
        29,
      );
    });

    test('rank thresholds are derived rather than table-driven', () {
      expect(MasteryService.pointsForNextRank(0), 20);
      expect(MasteryService.pointsForNextRank(10), 70);
      expect(MasteryService.rankForTotalXp(0), 0);
      expect(MasteryService.rankForTotalXp(20), 1);
      expect(MasteryService.rankForTotalXp(45), 2);
      expect(MasteryService.rankForTotalXp(1000000), 100);
    });
  });

  group('BenchmarkService', () {
    test('scores repetition work with load and variation difficulty', () {
      final exercise = _exercise(
        metric: ExerciseTrackingMetric.repetitions,
        sets: [
          WorkoutSetRecord(
            id: 'set-1',
            reps: 10,
            loadKg: 4,
            completed: true,
          ),
          WorkoutSetRecord(
            id: 'set-2',
            reps: 10,
            loadKg: 4,
            completed: true,
          ),
        ],
        difficulty: 1.2,
      );

      expect(BenchmarkService.score(exercise), closeTo(33.6, 1e-10));
    });

    test('distance only scores when duration is present', () {
      final missingDuration = _exercise(
        metric: ExerciseTrackingMetric.distanceMeters,
        sets: [
          WorkoutSetRecord(
            id: 'set-1',
            distanceMeters: 3000,
            completed: true,
          ),
        ],
      );
      final timed = _exercise(
        metric: ExerciseTrackingMetric.distanceMeters,
        sets: [
          WorkoutSetRecord(
            id: 'set-1',
            distanceMeters: 3000,
            durationSeconds: 1200,
            completed: true,
          ),
        ],
      );

      expect(BenchmarkService.score(missingDuration), 0);
      expect(BenchmarkService.score(timed), 3000);
    });

    test('personal record requires at least five percent improvement', () {
      expect(
        BenchmarkService.isPersonalRecord(score: 104.9, previousBest: 100),
        isFalse,
      );
      expect(
        BenchmarkService.isPersonalRecord(score: 105, previousBest: 100),
        isTrue,
      );
      expect(
        BenchmarkService.isPersonalRecord(score: 100, previousBest: 0),
        isFalse,
      );
    });
  });
}

ExerciseRecord _exercise({
  required ExerciseTrackingMetric metric,
  required List<WorkoutSetRecord> sets,
  double difficulty = 1,
}) {
  return ExerciseRecord(
    id: 'exercise',
    exerciseTypeIndex: ExerciseType.pushUp.index,
    movementId: 'push_up',
    displayName: 'Push Up',
    trackingMetricIndex: metric.index,
    variations: [
      VariationRecord(
        id: 'standard',
        name: 'Standard',
        difficultyMultiplier: difficulty,
        sets: sets,
      ),
    ],
  );
}
