import 'package:uuid/uuid.dart';

import '../../data/models/workout_plan_model.dart';
import '../enums/exercise_tracking_metric.dart';
import '../enums/exercise_type.dart';

class WorkoutPlanCatalog {
  WorkoutPlanCatalog._();

  static const String pplx2 = 'ppl_x2';
  static const String legsOnce = 'legs_once';

  static const Map<String, String> presetNames = {
    pplx2: 'PPL × 2',
    legsOnce: 'Legs Once',
  };

  static WorkoutPlanModel create({
    String presetId = pplx2,
    String fitnessLevel = 'Intermediate',
    DateTime? now,
  }) {
    final createdAt = now ?? DateTime.now();
    final normalizedPreset =
        presetNames.containsKey(presetId) ? presetId : pplx2;
    final days = normalizedPreset == legsOnce
        ? _legsOnceDays(fitnessLevel)
        : _pplx2Days(fitnessLevel);
    return WorkoutPlanModel(
      id: const Uuid().v4(),
      presetId: normalizedPreset,
      name: presetNames[normalizedPreset]!,
      days: days,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  static List<PlannedDayModel> _pplx2Days(String fitnessLevel) => [
        _day(1, WorkoutDayType.push, _pushExercises(fitnessLevel)),
        _day(2, WorkoutDayType.pull, _pullExercises(fitnessLevel)),
        _day(3, WorkoutDayType.legs, _legExercises(fitnessLevel)),
        _day(4, WorkoutDayType.push, _pushExercises(fitnessLevel)),
        _day(5, WorkoutDayType.pull, _pullExercises(fitnessLevel)),
        _day(6, WorkoutDayType.legs, _legExercises(fitnessLevel)),
        _restDay(7),
      ];

  static List<PlannedDayModel> _legsOnceDays(String fitnessLevel) => [
        _day(1, WorkoutDayType.push, _pushExercises(fitnessLevel)),
        _day(2, WorkoutDayType.pull, _pullExercises(fitnessLevel)),
        _day(3, WorkoutDayType.legs, _legExercises(fitnessLevel)),
        _day(4, WorkoutDayType.push, _pushExercises(fitnessLevel)),
        _day(5, WorkoutDayType.pull, _pullExercises(fitnessLevel)),
        _day(
          6,
          WorkoutDayType.conditioning,
          _conditioningExercises(fitnessLevel),
          isOptional: true,
        ),
        _restDay(7),
      ];

  static PlannedDayModel _day(
    int weekday,
    WorkoutDayType type,
    List<PlannedExerciseModel> exercises, {
    bool isOptional = false,
  }) {
    final typeName = switch (type) {
      WorkoutDayType.push => 'Push Day',
      WorkoutDayType.pull => 'Pull Day',
      WorkoutDayType.legs => 'Leg Day',
      WorkoutDayType.conditioning => 'Conditioning',
      WorkoutDayType.rest => 'Rest Day',
    };
    return PlannedDayModel(
      id: '${type.name}_$weekday',
      weekday: weekday,
      label: typeName,
      dayTypeIndex: type.index,
      isOptional: isOptional,
      exercises: exercises,
    );
  }

  static PlannedDayModel _restDay(int weekday) => PlannedDayModel(
        id: 'rest_$weekday',
        weekday: weekday,
        label: 'Rest Day',
        dayTypeIndex: WorkoutDayType.rest.index,
      );

  static List<PlannedExerciseModel> _pushExercises(String fitnessLevel) => [
        _exercise(
          type: ExerciseType.pushUp,
          movementId: 'push_up',
          name: 'Push Up',
          metric: ExerciseTrackingMetric.repetitions,
          variations: [
            _variation('standard', 'Standard', 4, _scaled(10, fitnessLevel), 1),
            _variation('wide', 'Wide', 4, _scaled(10, fitnessLevel), 1.05),
            _variation('diamond', 'Diamond', 4, _scaled(10, fitnessLevel), 1.2),
          ],
        ),
        _exercise(
          type: ExerciseType.shoulderRaise,
          movementId: 'shoulder_raise',
          name: 'Shoulder Raise',
          metric: ExerciseTrackingMetric.repetitions,
          variations: [
            _variation(
              'front',
              'Front',
              4,
              _scaled(10, fitnessLevel),
              0.8,
              loadKg: 4,
            ),
            _variation(
              'lateral',
              'Lateral',
              4,
              _scaled(10, fitnessLevel),
              0.9,
              loadKg: 4,
            ),
            _variation(
              'rear',
              'Rear',
              4,
              _scaled(10, fitnessLevel),
              0.9,
              loadKg: 4,
            ),
          ],
        ),
      ];

  static List<PlannedExerciseModel> _pullExercises(String fitnessLevel) => [
        _exercise(
          type: ExerciseType.pullUp,
          movementId: 'pull_up',
          name: 'Pull Up',
          metric: ExerciseTrackingMetric.repetitions,
          variations: [
            _variation(
                'standard', 'Standard', 4, _scaled(8, fitnessLevel), 1.4),
            _variation('wide', 'Wide', 4, _scaled(8, fitnessLevel), 1.55),
            _variation('chin_up', 'Chin-Up', 4, _scaled(8, fitnessLevel), 1.35),
          ],
        ),
        _exercise(
          type: ExerciseType.hangingCore,
          movementId: 'hanging_core',
          name: 'Hanging Core',
          metric: ExerciseTrackingMetric.durationSeconds,
          variations: [
            _variation('dead_hang', 'Dead Hang', 4, 60, 1),
          ],
        ),
        _exercise(
          type: ExerciseType.bicepCurl,
          movementId: 'bicep_curl',
          name: 'Bicep Curl',
          metric: ExerciseTrackingMetric.repetitions,
          variations: [
            _variation(
              'standard',
              'Standard',
              4,
              _scaled(12, fitnessLevel),
              0.9,
              loadKg: 4,
            ),
            _variation(
              'hammer',
              'Hammer',
              4,
              _scaled(12, fitnessLevel),
              1,
              loadKg: 4,
            ),
            _variation(
              'reverse',
              'Reverse',
              4,
              _scaled(12, fitnessLevel),
              1,
              loadKg: 4,
            ),
            _variation(
              'concentration',
              'Concentration',
              4,
              _scaled(12, fitnessLevel),
              1.05,
              loadKg: 4,
            ),
          ],
        ),
      ];

  static List<PlannedExerciseModel> _legExercises(String fitnessLevel) => [
        _exercise(
          type: ExerciseType.squat,
          movementId: 'squat',
          name: 'Squat',
          metric: ExerciseTrackingMetric.repetitions,
          variations: [
            _variation(
              'bodyweight',
              'Bodyweight',
              4,
              _scaled(10, fitnessLevel),
              1,
            ),
            _variation('sumo', 'Sumo', 4, _scaled(10, fitnessLevel), 1.05),
            _variation(
              'bulgarian',
              'Bulgarian',
              4,
              _scaled(10, fitnessLevel),
              1.3,
            ),
            _variation('jump', 'Jump', 4, _scaled(10, fitnessLevel), 1.35),
          ],
        ),
        _exercise(
          type: ExerciseType.calfRaise,
          movementId: 'calf_raise',
          name: 'Calf Raise',
          metric: ExerciseTrackingMetric.repetitions,
          variations: [
            _variation(
              'edge',
              'Edge Raise',
              4,
              _scaled(15, fitnessLevel),
              0.8,
            ),
          ],
        ),
        _exercise(
          type: ExerciseType.running,
          movementId: 'running',
          name: 'Run',
          metric: ExerciseTrackingMetric.distanceMeters,
          isOptional: true,
          variations: [
            _variation('easy_run', 'Easy Run', 1, 3000, 1),
          ],
        ),
      ];

  static List<PlannedExerciseModel> _conditioningExercises(
    String fitnessLevel,
  ) =>
      [
        _exercise(
          type: ExerciseType.running,
          movementId: 'running',
          name: 'Run',
          metric: ExerciseTrackingMetric.distanceMeters,
          isOptional: true,
          variations: [
            _variation('easy_run', 'Easy Run', 1, 3000, 1),
          ],
        ),
        _exercise(
          type: ExerciseType.cycling,
          movementId: 'cycling',
          name: 'Cycling',
          metric: ExerciseTrackingMetric.durationSeconds,
          isOptional: true,
          variations: [
            _variation('easy_ride', 'Easy Ride', 1, 1200, 1),
          ],
        ),
      ];

  static PlannedExerciseModel _exercise({
    required ExerciseType type,
    required String movementId,
    required String name,
    required ExerciseTrackingMetric metric,
    required List<VariationPlanModel> variations,
    bool isOptional = false,
  }) {
    return PlannedExerciseModel(
      id: movementId,
      exerciseTypeIndex: type.index,
      movementId: movementId,
      name: name,
      trackingMetricIndex: metric.index,
      variations: variations,
      isOptional: isOptional,
    );
  }

  static VariationPlanModel _variation(
    String id,
    String name,
    int sets,
    int value,
    double difficulty, {
    double loadKg = 0,
  }) {
    return VariationPlanModel(
      id: id,
      name: name,
      targetSets: sets,
      targetValue: value,
      targetLoadKg: loadKg,
      difficultyMultiplier: difficulty,
    );
  }

  static int _scaled(int base, String fitnessLevel) {
    final factor = switch (fitnessLevel) {
      'Beginner' => 0.8,
      'Advanced' => 1.15,
      _ => 1.0,
    };
    return (base * factor).round().clamp(1, 9999).toInt();
  }
}
