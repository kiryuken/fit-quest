import 'package:fitquest_rpg/core/data/exercise_definitions.dart';
import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkoutSelectionScreen extends ConsumerWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: AppSpacing.shellScreenPadding,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            eyebrow: 'Training deck',
            title: 'Choose your move',
            subtitle: 'Every set builds XP and shapes your attributes.',
            trailing: GlassIconBadge(
              icon: Icons.fitness_center_rounded,
              color: AppColors.turquoise,
              size: 50,
              iconSize: 23,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PremiumCard(
            backgroundColor: const Color(0x1F2DD4BF),
            child: Row(
              children: [
                const GlassIconBadge(
                  icon: Icons.auto_graph_rounded,
                  color: AppColors.turquoise,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Train with intent', style: AppTextStyles.cardTitle),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Choose a focus, track reps, and finish the session to bank your rewards.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Training modules',
            actionLabel: 'History',
            onAction: () => context.pushNamed(RouteNames.workoutHistory),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (final exercise in ExerciseDefinition.all)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _ExerciseCard(exercise: exercise),
            ),
        ],
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final ExerciseDefinition exercise;

  const _ExerciseCard({required this.exercise});

  @override
  Widget build(BuildContext context) {
    final primaryStat = exercise.statGains.keys.firstOrNull;
    final color = primaryStat == null
        ? AppColors.accent
        : AppColors.forStat(primaryStat.name);

    return PremiumCard(
      onTap: () => context.pushNamed(
        RouteNames.activeWorkout,
        pathParameters: {'exerciseName': exercise.name},
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          GlassIconBadge(
            icon: _iconFor(exercise.name),
            color: color,
            size: 54,
            iconSize: 24,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        exercise.name,
                        style: AppTextStyles.heading3,
                      ),
                    ),
                    GlassPill(
                      label: '+${exercise.expReward} XP',
                      color: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _StatBadges(gains: exercise.statGains),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textDimmed,
            size: 15,
          ),
        ],
      ),
    );
  }

  IconData _iconFor(String name) => switch (name) {
        'Push Up' => Icons.fitness_center_rounded,
        'Pull Up' => Icons.vertical_align_top_rounded,
        'Running' => Icons.directions_run_rounded,
        'Jump Rope' => Icons.loop_rounded,
        'Boxing' => Icons.sports_mma_rounded,
        _ => Icons.fitness_center_rounded,
      };
}

class _StatBadges extends StatelessWidget {
  final Map<StatType, int> gains;

  const _StatBadges({required this.gains});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final entry in gains.entries)
          GlassPill(
            label: '+${entry.value} ${entry.key.shortName}',
            color: AppColors.forStat(entry.key.name),
          ),
      ],
    );
  }
}
