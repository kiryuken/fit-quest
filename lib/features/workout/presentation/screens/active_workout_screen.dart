import 'dart:async';

import 'package:fitquest_rpg/core/data/exercise_definitions.dart';
import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/achievement_state.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/providers/achievement_provider.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/quest_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  final String exerciseName;

  const ActiveWorkoutScreen({super.key, required this.exerciseName});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  int _elapsedSeconds = 0;
  int _trackedAmount = 0;
  int _sets = 1;
  Timer? _timer;
  bool _isRunning = false;
  bool _isFinishing = false;
  late final ExerciseDefinition _exercise;

  @override
  void initState() {
    super.initState();
    _exercise = ExerciseDefinition.all.firstWhere(
      (exercise) => exercise.name == widget.exerciseName,
      orElse: () => ExerciseDefinition.all.first,
    );
  }

  void _toggleTimer() {
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _elapsedSeconds++);
      });
      setState(() => _isRunning = true);
    }
  }

  void _adjustTrackedAmount(int amount) {
    setState(
      () => _trackedAmount = (_trackedAmount + amount).clamp(0, 99999),
    );
  }

  void _addSet() => setState(() => _sets++);

  String get _timeDisplay {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _finishWorkout() async {
    if (_isFinishing) return;
    setState(() => _isFinishing = true);
    _timer?.cancel();

    final userNotifier = ref.read(userProvider.notifier);
    final achievementNotifier = ref.read(achievementProvider.notifier);
    final questNotifier = ref.read(questProvider.notifier);
    final workoutRepo = ref.read(workoutRepositoryProvider);
    final totalSets = _sets;
    final trackedAmount = _trackedAmount;
    final duration = _elapsedSeconds;
    const formQuality = 0.8;
    final totalXp = _exercise.expReward * totalSets;
    final questProgress = _exercise.questProgressFor(
      trackedAmount,
      sets: totalSets,
    );

    final workout = WorkoutModel(
      id: const Uuid().v4(),
      date: DateTime.now(),
      durationSeconds: duration,
      exercises: [
        ExerciseRecord(
          id: const Uuid().v4(),
          exerciseTypeIndex: _exercise.type.index,
          sets: totalSets,
          reps: _exercise.repetitionsFor(trackedAmount),
          durationSeconds: duration,
          formQuality: formQuality,
          xpEarned: totalXp,
          distanceMeters: _exercise.distanceMetersFor(trackedAmount),
        ),
      ],
      totalXpEarned: totalXp,
      statXpGained: _exercise.statGains.map(
        (stat, value) => MapEntry(stat.index, value * totalSets),
      ),
      completed: true,
      createdAt: DateTime.now(),
    );

    try {
      await workoutRepo.saveWorkout(workout);
      await userNotifier.completeWorkout(
        xpGained: totalXp,
        statGains: _exercise.statGains.map(
          (stat, value) => MapEntry(stat, value * totalSets),
        ),
      );

      achievementNotifier.unlock(AchievementCatalog.firstWorkout);

      final quests = ref.read(questProvider);
      for (final quest in quests) {
        if (quest.id.startsWith(_exercise.questSlug)) {
          await questNotifier.addProgress(
            quest.id,
            questProgress,
          );
          break;
        }
      }

      if (mounted) {
        context.pushNamed(
          RouteNames.workoutComplete,
          queryParameters: {
            'xp': '$totalXp',
            'duration': '$duration',
            'sets': '$totalSets',
            'reps': '$questProgress',
            'trackingLabel': _exercise.trackingMetric.displayLabel,
            'trackingUnit': _exercise.trackingMetric.shortLabel,
            'exercise': _exercise.name,
          },
        );
      }
    } finally {
      if (mounted) setState(() => _isFinishing = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statColor = AppColors.forStat(_exercise.statGains.keys.first.name);
    return AuroraScaffold(
      title: _exercise.name,
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Close workout',
        onPressed: () => context.pop(),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: constraints.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GlassPill(
                            icon: _isRunning
                                ? Icons.graphic_eq_rounded
                                : Icons.pause_rounded,
                            label: _isRunning ? 'SESSION LIVE' : 'READY',
                            color: _isRunning
                                ? AppColors.turquoise
                                : AppColors.textDimmed,
                          ),
                          const Spacer(),
                          GlassPill(
                            icon: Icons.bolt_rounded,
                            label: '+${_exercise.expReward * _sets} XP',
                            color: AppColors.gold,
                          ),
                        ],
                      ),
                      const Spacer(),
                      GlassContainer(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        child: Column(
                          children: [
                            Text('SESSION TIME',
                                style: AppTextStyles.sectionTitle),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              _timeDisplay,
                              style: AppTextStyles.timerDisplay,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _isRunning
                                  ? 'Stay in rhythm. You are building momentum.'
                                  : 'Tap play when you are ready to move.',
                              style: AppTextStyles.caption,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Container(
                              height: 1,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppColors.glassBorder,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                                _exercise.trackingMetric.displayLabel
                                    .toUpperCase(),
                                style: AppTextStyles.sectionTitle),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _ControlButton(
                                  icon: Icons.remove_rounded,
                                  color: statColor,
                                  onTap: () => _adjustTrackedAmount(
                                    -_exercise.trackingMetric.inputStep,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                SizedBox(
                                  width: 108,
                                  child: Column(
                                    children: [
                                      Text(
                                        '$_trackedAmount',
                                        style: AppTextStyles.repCounter,
                                      ),
                                      Text(
                                        _exercise.trackingMetric.shortLabel,
                                        style: AppTextStyles.pillLabel,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.xl),
                                _ControlButton(
                                  icon: Icons.add_rounded,
                                  color: statColor,
                                  onTap: () => _adjustTrackedAmount(
                                    _exercise.trackingMetric.inputStep,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            PremiumCard(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.md,
                              ),
                              child: Row(
                                children: [
                                  GlassIconBadge(
                                    icon: Icons.layers_rounded,
                                    color: statColor,
                                    size: 42,
                                    iconSize: 19,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$_sets set${_sets == 1 ? '' : 's'}',
                                          style: AppTextStyles.cardTitle,
                                        ),
                                        Text(
                                          'Each set multiplies your reward',
                                          style: AppTextStyles.caption,
                                        ),
                                      ],
                                    ),
                                  ),
                                  _ControlButton(
                                    icon: Icons.add_rounded,
                                    color: AppColors.turquoise,
                                    size: 42,
                                    onTap: _addSet,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Semantics(
                        button: true,
                        label: _isRunning ? 'Pause timer' : 'Start timer',
                        child: InkWell(
                          borderRadius: BorderRadius.circular(44),
                          onTap: _toggleTimer,
                          child: AnimatedContainer(
                            duration: AppSpacing.standard,
                            width: 86,
                            height: 86,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: _isRunning
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.danger,
                                        AppColors.pink,
                                      ],
                                    )
                                  : AppColors.coolGradient,
                              border:
                                  Border.all(color: AppColors.glassHighlight),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRunning
                                          ? AppColors.danger
                                          : AppColors.accent)
                                      .withValues(alpha: 0.45),
                                  blurRadius: 30,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.textPrimary,
                              size: 38,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        width: double.infinity,
                        child: GradientActionButton(
                          label: 'FINISH SESSION',
                          icon: Icons.flag_rounded,
                          loading: _isFinishing,
                          gradient: AppColors.rewardGradient,
                          foregroundColor: AppColors.textInverse,
                          onPressed: _isFinishing ? null : _finishWorkout,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.color,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.38)),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.14),
                blurRadius: 14,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: size * 0.44),
        ),
      ),
    );
  }
}
