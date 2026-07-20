import 'package:fitquest_rpg/core/enums/exercise_tracking_metric.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class WorkoutDetailScreen extends ConsumerWidget {
  final String id;

  const WorkoutDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<WorkoutModel?>(
      future: ref.watch(workoutRepositoryProvider).getWorkout(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AuroraScaffold(
            title: 'Workout detail',
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return AuroraScaffold(
            title: 'Workout detail',
            body: EmptyGlassState(
              icon: Icons.error_outline_rounded,
              title: 'Workout could not be read',
              message: '${snapshot.error}',
            ),
          );
        }

        final workout = snapshot.data;
        if (workout == null) {
          return const AuroraScaffold(
            title: 'Workout detail',
            body: EmptyGlassState(
              icon: Icons.search_off_rounded,
              title: 'Workout not found',
              message: 'This session is no longer available.',
            ),
          );
        }
        return _WorkoutDetail(workout: workout);
      },
    );
  }
}

class _WorkoutDetail extends StatelessWidget {
  final WorkoutModel workout;

  const _WorkoutDetail({required this.workout});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
    final timeFormat = DateFormat('HH:mm');
    final mastery = workout.masteryPoints.values.fold<int>(
      0,
      (total, points) => total + points,
    );
    return AuroraScaffold(
      title: 'Workout detail',
      body: ListView(
        padding: AppSpacing.screenPadding,
        physics: const BouncingScrollPhysics(),
        children: [
          PageHeader(
            eyebrow: 'Session record',
            title: dateFormat.format(workout.date),
            subtitle:
                '${timeFormat.format(workout.date)} · ${workout.durationSeconds ~/ 60} min',
            trailing: GlassIconBadge(
              icon: workout.isCommitted
                  ? Icons.check_rounded
                  : Icons.sync_rounded,
              color: workout.isCommitted ? AppColors.turquoise : AppColors.gold,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Text('SESSION OUTPUT', style: AppTextStyles.sectionTitle),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'Character XP',
                        value: '+${workout.totalXpEarned}',
                        icon: Icons.bolt_rounded,
                        color: AppColors.gold,
                      ),
                    ),
                    Expanded(
                      child: MetricTile(
                        label: 'Valid sets',
                        value:
                            '${workout.validSetCount}/${workout.plannedSetCount}',
                        icon: Icons.done_all_rounded,
                        color: AppColors.turquoise,
                      ),
                    ),
                    Expanded(
                      child: MetricTile(
                        label: 'Mastery',
                        value: '+$mastery',
                        icon: Icons.auto_awesome_rounded,
                        color: AppColors.pink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                LiquidProgressBar(
                  value: workout.completionRate,
                  height: 7,
                  color: AppColors.turquoise,
                  endColor: AppColors.accent,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Exercise hierarchy'),
          const SizedBox(height: AppSpacing.md),
          for (final exercise in workout.exercises)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ExerciseRecordCard(exercise: exercise),
            ),
        ],
      ),
    );
  }
}

class _ExerciseRecordCard extends StatelessWidget {
  final ExerciseRecord exercise;

  const _ExerciseRecordCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final color = const [
      AppColors.accent,
      AppColors.turquoise,
      AppColors.pink,
      AppColors.gold,
    ][exercise.orderIndex % 4];
    return PremiumCard(
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
                    Text(exercise.displayName, style: AppTextStyles.heading3),
                    Text(
                      '${exercise.validSetCount}/${exercise.plannedSetCount} valid sets',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              if (exercise.isPersonalRecord)
                const GlassPill(
                  icon: Icons.workspace_premium_rounded,
                  label: 'PR',
                  color: AppColors.gold,
                )
              else
                GlassPill(
                  label: '+${exercise.masteryEarned} MASTERY',
                  color: AppColors.pink,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final variation in exercise.variations) ...[
            Text(variation.name, style: AppTextStyles.cardTitle),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var index = 0; index < variation.sets.length; index++)
                  _SetPill(
                    index: index,
                    set: variation.sets[index],
                    metric: exercise.trackingMetric,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _SetPill extends StatelessWidget {
  final int index;
  final WorkoutSetRecord set;
  final ExerciseTrackingMetric metric;

  const _SetPill({
    required this.index,
    required this.set,
    required this.metric,
  });

  @override
  Widget build(BuildContext context) {
    final valid = set.isValid(metric);
    final value = switch (metric) {
      ExerciseTrackingMetric.repetitions => '${set.reps} reps',
      ExerciseTrackingMetric.durationSeconds => '${set.durationSeconds} sec',
      ExerciseTrackingMetric.distanceMeters =>
        '${set.distanceMeters.toStringAsFixed(0)} m',
    };
    return GlassPill(
      icon: valid ? Icons.check_rounded : Icons.close_rounded,
      label: 'S${index + 1} · $value · RPE ${set.rpe}',
      color: valid ? AppColors.turquoise : AppColors.textDimmed,
    );
  }
}
