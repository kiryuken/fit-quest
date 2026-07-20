import 'package:fitquest_rpg/core/data/workout_plan_catalog.dart';
import 'package:fitquest_rpg/core/enums/exercise_tracking_metric.dart';
import 'package:fitquest_rpg/domain/services/weekly_plan_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutPlanCatalog', () {
    test('PPL x2 follows Push Pull Legs twice then Rest', () {
      final plan = WorkoutPlanCatalog.create(
        presetId: WorkoutPlanCatalog.pplx2,
        fitnessLevel: 'Intermediate',
        now: DateTime(2026, 7, 20),
      );

      expect(
        plan.days.map((day) => day.label),
        [
          'Push Day',
          'Pull Day',
          'Leg Day',
          'Push Day',
          'Pull Day',
          'Leg Day',
          'Rest Day',
        ],
      );
      expect(plan.days[0].plannedSetCount, 24);
      expect(plan.days[1].plannedSetCount, 32);
      expect(plan.days[2].plannedSetCount, 20);
    });

    test('normal targets match the specified exercise scenario', () {
      final plan = WorkoutPlanCatalog.create(
        fitnessLevel: 'Intermediate',
        now: DateTime(2026, 7, 20),
      );
      final push = plan.days[0];
      final pull = plan.days[1];
      final legs = plan.days[2];

      expect(
        push.exercises[0].variations
            .map((variation) => (variation.targetSets, variation.targetValue)),
        [(4, 10), (4, 10), (4, 10)],
      );
      expect(
        pull.exercises[0].variations.map((variation) => variation.targetValue),
        [8, 8, 8],
      );
      expect(pull.exercises[1].trackingMetric,
          ExerciseTrackingMetric.durationSeconds);
      expect(pull.exercises[1].variations.single.targetValue, 60);
      expect(legs.exercises.last.trackingMetric,
          ExerciseTrackingMetric.distanceMeters);
      expect(legs.exercises.last.variations.single.targetValue, 3000);
    });

    test('Legs Once makes Saturday optional conditioning', () {
      final plan = WorkoutPlanCatalog.create(
        presetId: WorkoutPlanCatalog.legsOnce,
        fitnessLevel: 'Intermediate',
        now: DateTime(2026, 7, 20),
      );

      expect(plan.days.where((day) => day.label == 'Leg Day'), hasLength(1));
      expect(plan.days[5].isOptional, isTrue);
      expect(plan.days[5].countsForStreak, isFalse);
      expect(plan.days[6].isRest, isTrue);
    });
  });

  group('WeeklyPlanService', () {
    final plan = WorkoutPlanCatalog.create(
      presetId: WorkoutPlanCatalog.legsOnce,
      fitnessLevel: 'Intermediate',
      now: DateTime(2026, 7, 20),
    );

    test('only future calendar dates are editable', () {
      final now = DateTime(2026, 7, 20, 18);
      expect(
        WeeklyPlanService.canEditDate(
          targetDate: DateTime(2026, 7, 20, 23),
          now: now,
        ),
        isFalse,
      );
      expect(
        WeeklyPlanService.canEditDate(
          targetDate: DateTime(2026, 7, 21),
          now: now,
        ),
        isTrue,
      );
    });

    test('rest and optional days are excluded from required adherence', () {
      final required = WeeklyPlanService.requiredDates(
        plan: plan,
        from: DateTime(2026, 7, 20),
        through: DateTime(2026, 7, 26),
      );

      expect(required, hasLength(5));
      expect(required.any((date) => date.weekday == DateTime.saturday), false);
      expect(required.any((date) => date.weekday == DateTime.sunday), false);
      expect(
        WeeklyPlanService.adherence(
          plan: plan,
          from: DateTime(2026, 7, 20),
          through: DateTime(2026, 7, 26),
          completedDates: required.take(4),
        ),
        0.8,
      );
    });
  });
}
