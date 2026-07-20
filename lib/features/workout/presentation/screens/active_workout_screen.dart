import 'dart:async';

import 'package:fitquest_rpg/core/enums/exercise_tracking_metric.dart';
import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/data/models/workout_plan_model.dart';
import 'package:fitquest_rpg/domain/services/workout_completion_service.dart';
import 'package:fitquest_rpg/domain/services/workout_reward_service.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/weekly_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  /// Kept for route/backward compatibility. A session now always uses the
  /// complete scheduled day instead of granting rewards per exercise.
  final String exerciseName;

  const ActiveWorkoutScreen({
    super.key,
    this.exerciseName = 'Today',
  });

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  final Uuid _uuid = const Uuid();
  final List<_ExerciseDraft> _drafts = [];
  Timer? _timer;
  String? _initializedDayId;
  int _elapsedSeconds = 0;
  bool _isRunning = false;
  bool _isFinishing = false;

  void _initialize(PlannedDayModel day) {
    if (_initializedDayId == day.id) return;
    _initializedDayId = day.id;
    _drafts
      ..clear()
      ..addAll(
        day.exercises.map(
          (exercise) => _ExerciseDraft(
            plan: exercise,
            variations: exercise.variations
                .map(
                  (variation) => _VariationDraft(
                    plan: variation,
                    sets: List.generate(
                      variation.targetSets,
                      (_) => _SetDraft(
                        id: _uuid.v4(),
                        value: variation.targetValue,
                        loadKg: variation.targetLoadKg,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _elapsedSeconds++);
    });
    setState(() => _isRunning = true);
  }

  int get _plannedSets => _drafts.fold(
        0,
        (total, exercise) => total + exercise.plannedSetCount,
      );

  int get _validSets => _drafts.fold(
        0,
        (total, exercise) => total + exercise.validSetCount,
      );

  int get _validFamilies =>
      _drafts.where((exercise) => exercise.validSetCount > 0).length;

  double get _completionRate =>
      _plannedSets == 0 ? 0 : _validSets / _plannedSets;

  int get _estimatedXp => WorkoutRewardService.calculateSessionXp(
        exerciseFamilies: _validFamilies,
        validSets: _validSets,
        plannedSets: _plannedSets,
        completionRate: _completionRate,
      );

  String get _timeDisplay {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  void _toggleSet(
    _ExerciseDraft exercise,
    _SetDraft set,
    bool completed,
  ) {
    setState(() => set.completed = completed);
  }

  void _adjustValue(
    ExerciseTrackingMetric metric,
    _SetDraft set,
    int direction,
  ) {
    final next = set.value + (metric.inputStep * direction);
    setState(() => set.value = next.clamp(0, 100000));
  }

  void _adjustRpe(_SetDraft set, int direction) {
    setState(() => set.rpe = (set.rpe + direction).clamp(1, 10));
  }

  void _markAll(bool completed) {
    setState(() {
      for (final exercise in _drafts) {
        for (final variation in exercise.variations) {
          for (final set in variation.sets) {
            set.completed = completed;
          }
        }
      }
    });
  }

  WorkoutModel _buildWorkout(
    WorkoutPlanModel plan,
    PlannedDayModel day,
  ) {
    final now = ref.read(clockProvider).now();
    final workoutId = _uuid.v4();
    final exercises = <ExerciseRecord>[];

    for (var exerciseIndex = 0;
        exerciseIndex < _drafts.length;
        exerciseIndex++) {
      final draft = _drafts[exerciseIndex];
      final metric = draft.plan.trackingMetric;
      final variations = draft.variations
          .map(
            (variation) => VariationRecord(
              id: variation.plan.id,
              name: variation.plan.name,
              difficultyMultiplier: variation.plan.difficultyMultiplier,
              sets: variation.sets
                  .map(
                    (set) => WorkoutSetRecord(
                      id: set.id,
                      reps: metric == ExerciseTrackingMetric.repetitions
                          ? set.value
                          : 0,
                      durationSeconds:
                          metric == ExerciseTrackingMetric.durationSeconds
                              ? set.value
                              : metric == ExerciseTrackingMetric.distanceMeters
                                  ? _elapsedSeconds
                                  : 0,
                      distanceMeters:
                          metric == ExerciseTrackingMetric.distanceMeters
                              ? set.value.toDouble()
                              : 0,
                      loadKg: set.loadKg,
                      rpe: set.rpe,
                      completed: set.completed,
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false);
      exercises.add(
        ExerciseRecord(
          id: _uuid.v4(),
          exerciseTypeIndex: draft.plan.exerciseTypeIndex,
          movementId: draft.plan.movementId,
          displayName: draft.plan.name,
          trackingMetricIndex: metric.index,
          variations: variations,
          orderIndex: exerciseIndex,
          sets: draft.plannedSetCount,
        ),
      );
    }

    return WorkoutModel(
      id: workoutId,
      eventId: 'workout:$workoutId',
      date: now,
      durationSeconds: _elapsedSeconds,
      exercises: exercises,
      createdAt: now,
      planId: plan.id,
      plannedDayId: day.id,
      processingStateIndex: WorkoutProcessingState.pending.index,
      completionRate: _completionRate,
      scheduled: !day.isOptional,
      countsForStreak: day.countsForStreak,
    );
  }

  Future<void> _finish(
    WorkoutPlanModel plan,
    PlannedDayModel day,
  ) async {
    if (_isFinishing) return;
    if (_completionRate < WorkoutRewardService.minimumCompletionRate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete at least 50% of the planned sets before finishing.',
          ),
        ),
      );
      return;
    }

    setState(() => _isFinishing = true);
    _timer?.cancel();
    try {
      final result = await ref
          .read(workoutCompletionServiceProvider)
          .complete(_buildWorkout(plan, day));
      if (!mounted) return;
      context.pushReplacementNamed(
        RouteNames.workoutComplete,
        queryParameters: {
          'xp': '${result.xpAwarded}',
          'duration': '${result.workout.durationSeconds}',
          'sets': '${result.workout.validSetCount}',
          'reps': '${result.workout.plannedSetCount}',
          'trackingLabel': 'Completion',
          'trackingUnit': 'SETS',
          'exercise': day.label,
        },
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Workout was not committed: $error')),
      );
      setState(() => _isFinishing = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(weeklyPlanProvider);
    return planAsync.when(
      loading: () => const AuroraScaffold(
        title: 'Active workout',
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => AuroraScaffold(
        title: 'Active workout',
        body: EmptyGlassState(
          icon: Icons.error_outline_rounded,
          title: 'Plan unavailable',
          message: '$error',
        ),
      ),
      data: (plan) {
        final day = plan.dayFor(ref.read(clockProvider).now());
        _initialize(day);
        if (day.isRest) {
          return const AuroraScaffold(
            title: 'Recovery day',
            body: EmptyGlassState(
              icon: Icons.bedtime_rounded,
              title: 'Rest preserves progress',
              message:
                  'Recovery is part of the plan. No workout is scheduled today.',
            ),
          );
        }
        return _buildSession(context, plan, day);
      },
    );
  }

  Widget _buildSession(
    BuildContext context,
    WorkoutPlanModel plan,
    PlannedDayModel day,
  ) {
    final completionPercent = (_completionRate * 100).round();
    return AuroraScaffold(
      title: day.label,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Close workout',
        onPressed: _isFinishing ? null : () => context.pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        physics: const BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              GlassPill(
                icon:
                    _isRunning ? Icons.graphic_eq_rounded : Icons.pause_rounded,
                label: _isRunning ? 'SESSION LIVE' : _timeDisplay,
                color: _isRunning ? AppColors.turquoise : AppColors.textDimmed,
              ),
              const Spacer(),
              GlassPill(
                icon: Icons.bolt_rounded,
                label: 'EST. +$_estimatedXp XP',
                color: AppColors.gold,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(_timeDisplay, style: AppTextStyles.heading2),
                    const Spacer(),
                    IconButton.filledTonal(
                      tooltip: _isRunning ? 'Pause timer' : 'Start timer',
                      onPressed: _toggleTimer,
                      icon: Icon(
                        _isRunning
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                LiquidProgressBar(
                  value: _completionRate,
                  height: 9,
                  color: completionPercent >= 50
                      ? AppColors.turquoise
                      : AppColors.accent,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '$_validSets / $_plannedSets valid sets',
                      style: AppTextStyles.caption,
                    ),
                    const Spacer(),
                    Text('$completionPercent%', style: AppTextStyles.cardTitle),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    key: const Key('mark-all-sets'),
                    onPressed: () => _markAll(_validSets < _plannedSets),
                    icon: const Icon(Icons.done_all_rounded),
                    label: Text(
                      _validSets < _plannedSets ? 'Mark all' : 'Clear all',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          for (final exercise in _drafts)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _ExerciseEditor(
                draft: exercise,
                onToggle: (set, completed) =>
                    _toggleSet(exercise, set, completed),
                onAdjustValue: _adjustValue,
                onAdjustRpe: _adjustRpe,
              ),
            ),
          const SizedBox(height: AppSpacing.sm),
          GradientActionButton(
            key: const Key('finish-workout'),
            label: completionPercent >= 50
                ? 'FINISH · +$_estimatedXp XP'
                : 'COMPLETE 50% TO FINISH',
            icon: Icons.flag_rounded,
            loading: _isFinishing,
            onPressed: _isFinishing ? null : () => _finish(plan, day),
          ),
        ],
      ),
    );
  }
}

class _ExerciseEditor extends StatelessWidget {
  final _ExerciseDraft draft;
  final void Function(_SetDraft set, bool completed) onToggle;
  final void Function(
    ExerciseTrackingMetric metric,
    _SetDraft set,
    int direction,
  ) onAdjustValue;
  final void Function(_SetDraft set, int direction) onAdjustRpe;

  const _ExerciseEditor({
    required this.draft,
    required this.onToggle,
    required this.onAdjustValue,
    required this.onAdjustRpe,
  });

  @override
  Widget build(BuildContext context) {
    final color = _exerciseColor(draft.plan.exerciseTypeIndex);
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIconBadge(
                icon: Icons.fitness_center_rounded,
                color: color,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(draft.plan.name, style: AppTextStyles.heading3),
                    Text(
                      '${draft.validSetCount}/${draft.plannedSetCount} valid sets'
                      '${draft.plan.isOptional ? ' · optional' : ''}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final variation in draft.variations) ...[
            Text(variation.plan.name, style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < variation.sets.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _SetEditor(
                  key: Key('${draft.plan.id}-${variation.plan.id}-$index'),
                  index: index,
                  metric: draft.plan.trackingMetric,
                  set: variation.sets[index],
                  onToggle: onToggle,
                  onAdjustValue: onAdjustValue,
                  onAdjustRpe: onAdjustRpe,
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _SetEditor extends StatelessWidget {
  final int index;
  final ExerciseTrackingMetric metric;
  final _SetDraft set;
  final void Function(_SetDraft set, bool completed) onToggle;
  final void Function(
    ExerciseTrackingMetric metric,
    _SetDraft set,
    int direction,
  ) onAdjustValue;
  final void Function(_SetDraft set, int direction) onAdjustRpe;

  const _SetEditor({
    super.key,
    required this.index,
    required this.metric,
    required this.set,
    required this.onToggle,
    required this.onAdjustValue,
    required this.onAdjustRpe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: set.completed
            ? AppColors.turquoise.withValues(alpha: 0.08)
            : AppColors.glassBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: set.completed
              ? AppColors.turquoise.withValues(alpha: 0.4)
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Checkbox(
            value: set.completed,
            onChanged: (value) => onToggle(set, value ?? false),
          ),
          Text('${index + 1}', style: AppTextStyles.cardMeta),
          const SizedBox(width: AppSpacing.sm),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Decrease ${metric.displayLabel}',
            onPressed: () => onAdjustValue(metric, set, -1),
            icon: const Icon(Icons.remove_rounded, size: 18),
          ),
          Expanded(
            child: Text(
              '${set.value} ${metric.shortLabel.toLowerCase()}',
              textAlign: TextAlign.center,
              style: AppTextStyles.cardTitle,
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Increase ${metric.displayLabel}',
            onPressed: () => onAdjustValue(metric, set, 1),
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkWell(
            onTap: () => onAdjustRpe(set, 1),
            onLongPress: () => onAdjustRpe(set, -1),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Text(
                'RPE ${set.rpe}',
                style: AppTextStyles.pillLabel.copyWith(
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseDraft {
  final PlannedExerciseModel plan;
  final List<_VariationDraft> variations;

  const _ExerciseDraft({
    required this.plan,
    required this.variations,
  });

  int get plannedSetCount => variations.fold(
        0,
        (total, variation) => total + variation.sets.length,
      );

  int get validSetCount => variations.fold(
        0,
        (total, variation) =>
            total +
            variation.sets
                .where(
                  (set) =>
                      set.completed &&
                      plan.trackingMetric.isValid(
                        reps: plan.trackingMetric ==
                                ExerciseTrackingMetric.repetitions
                            ? set.value
                            : 0,
                        durationSeconds: plan.trackingMetric ==
                                ExerciseTrackingMetric.durationSeconds
                            ? set.value
                            : 0,
                        distanceMeters: plan.trackingMetric ==
                                ExerciseTrackingMetric.distanceMeters
                            ? set.value.toDouble()
                            : 0,
                      ),
                )
                .length,
      );
}

class _VariationDraft {
  final VariationPlanModel plan;
  final List<_SetDraft> sets;

  const _VariationDraft({
    required this.plan,
    required this.sets,
  });
}

class _SetDraft {
  final String id;
  int value;
  double loadKg;
  int rpe;
  bool completed;

  _SetDraft({
    required this.id,
    required this.value,
    required this.loadKg,
  })  : rpe = 7,
        completed = false;
}

Color _exerciseColor(int index) => const [
      AppColors.accent,
      AppColors.turquoise,
      AppColors.pink,
      AppColors.gold,
      AppColors.info,
    ][index % 5];
