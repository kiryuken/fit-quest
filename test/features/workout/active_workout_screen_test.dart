import 'package:fitquest_rpg/core/data/workout_plan_catalog.dart';
import 'package:fitquest_rpg/core/time/app_clock.dart';
import 'package:fitquest_rpg/data/models/workout_plan_model.dart';
import 'package:fitquest_rpg/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/weekly_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('active Leg Day tracks the whole hierarchy and running meters',
      (tester) async {
    final now = DateTime(2026, 7, 22, 18); // Wednesday
    final plan = WorkoutPlanCatalog.create(
      fitnessLevel: 'Intermediate',
      now: now,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          clockProvider.overrideWithValue(FixedAppClock(now)),
          weeklyPlanProvider.overrideWith(
            () => _FixedWeeklyPlanNotifier(plan),
          ),
        ],
        child: const MaterialApp(home: ActiveWorkoutScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Leg Day'), findsWidgets);
    expect(find.text('Squat'), findsOneWidget);

    await tester.tap(find.byKey(const Key('mark-all-sets')));
    await tester.pump();
    expect(find.text('21 / 21 valid sets'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Run'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Run'), findsOneWidget);
    expect(find.text('3000 meters'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('finish-workout')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('FINISH · +'), findsOneWidget);
  });
}

class _FixedWeeklyPlanNotifier extends WeeklyPlanNotifier {
  final WorkoutPlanModel plan;

  _FixedWeeklyPlanNotifier(this.plan);

  @override
  Future<WorkoutPlanModel> build() async => plan;
}
