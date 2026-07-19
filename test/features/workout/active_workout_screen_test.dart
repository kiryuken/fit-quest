import 'package:fitquest_rpg/features/workout/presentation/screens/active_workout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('running input is measured in 100 meter steps', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ActiveWorkoutScreen(exerciseName: 'Running'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DISTANCE'), findsOneWidget);
    expect(find.text('METERS'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded).first);
    await tester.pump();

    expect(find.text('100'), findsOneWidget);
  });
}
