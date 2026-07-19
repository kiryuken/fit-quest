import 'package:fitquest_rpg/core/data/exercise_definitions.dart';
import 'package:fitquest_rpg/core/enums/exercise_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every selectable exercise has the correct persisted type', () {
    expect(
      {
        for (final exercise in ExerciseDefinition.all)
          exercise.name: exercise.type,
      },
      {
        'Push Up': ExerciseType.pushUp,
        'Pull Up': ExerciseType.pullUp,
        'Running': ExerciseType.running,
        'Jump Rope': ExerciseType.jumpRope,
        'Boxing': ExerciseType.boxing,
      },
    );
  });

  test('running tracks distance while other exercises track repetitions', () {
    final running = ExerciseDefinition.all.firstWhere(
      (exercise) => exercise.type == ExerciseType.running,
    );
    final pushUp = ExerciseDefinition.all.firstWhere(
      (exercise) => exercise.type == ExerciseType.pushUp,
    );

    expect(
      running.trackingMetric,
      ExerciseTrackingMetric.distanceMeters,
    );
    expect(running.trackingMetric.inputStep, 100);
    expect(running.questProgressFor(3000), 3000);
    expect(running.questProgressFor(3000, sets: 2), 3000);
    expect(running.repetitionsFor(3000), 0);
    expect(running.distanceMetersFor(3000), 3000);

    expect(
      pushUp.trackingMetric,
      ExerciseTrackingMetric.repetitions,
    );
    expect(pushUp.questProgressFor(20, sets: 3), 60);
    expect(pushUp.repetitionsFor(20), 20);
    expect(pushUp.distanceMetersFor(20), 0);
  });
}
