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
    final workoutRepo = ref.watch(workoutRepositoryProvider);

    return FutureBuilder<WorkoutModel?>(
      future: workoutRepo.getWorkout(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AuroraScaffold(
            title: 'Workout detail',
            body: Center(child: CircularProgressIndicator()),
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

        final dateFormat = DateFormat('EEEE, MMMM dd, yyyy');
        final timeFormat = DateFormat('HH:mm');
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
                trailing: const GlassIconBadge(
                  icon: Icons.check_rounded,
                  color: AppColors.turquoise,
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
                            label: 'Total XP',
                            value: '+${workout.totalXpEarned}',
                            icon: Icons.bolt_rounded,
                            color: AppColors.gold,
                          ),
                        ),
                        Expanded(
                          child: MetricTile(
                            label: 'Exercises',
                            value: '${workout.exercises.length}',
                            icon: Icons.fitness_center_rounded,
                            color: AppColors.accent,
                          ),
                        ),
                        Expanded(
                          child: MetricTile(
                            label: 'Status',
                            value: workout.completed ? 'Done' : 'Open',
                            icon: Icons.flag_rounded,
                            color: AppColors.turquoise,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Exercises'),
              const SizedBox(height: AppSpacing.md),
              for (final exercise in workout.exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: PremiumCard(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GlassIconBadge(
                          icon: Icons.fitness_center_rounded,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise.exerciseType.displayName,
                                style: AppTextStyles.heading3,
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.sm,
                                children: [
                                  GlassPill(
                                    label: '${exercise.sets} SETS',
                                    color: AppColors.accent,
                                  ),
                                  GlassPill(
                                    label: exercise.distanceMeters > 0
                                        ? '${exercise.distanceMeters.round()} METERS'
                                        : '${exercise.reps} REPS',
                                    color: AppColors.turquoise,
                                  ),
                                  GlassPill(
                                    label: '${exercise.durationSeconds} SEC',
                                    color: AppColors.pink,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '+${exercise.xpEarned} XP',
                          style: AppTextStyles.xpGain,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
