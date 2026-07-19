import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryScreen extends ConsumerWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutRepo = ref.watch(workoutRepositoryProvider);

    return AuroraScaffold(
      title: 'Workout history',
      body: FutureBuilder<List<WorkoutModel>>(
        future: workoutRepo.getAllWorkouts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return const EmptyGlassState(
              icon: Icons.history_rounded,
              title: 'No sessions yet',
              message: 'Complete your first workout and it will appear here.',
            );
          }

          final totalXp = workouts.fold<int>(
            0,
            (sum, workout) => sum + workout.totalXpEarned,
          );
          return ListView(
            padding: AppSpacing.screenPadding,
            physics: const BouncingScrollPhysics(),
            children: [
              PageHeader(
                eyebrow: 'Training archive',
                title: '${workouts.length} sessions',
                subtitle: 'A record of every rep that moved you forward.',
                trailing: GlassPill(
                  icon: Icons.bolt_rounded,
                  label: '$totalXp XP',
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Recent activity'),
              const SizedBox(height: AppSpacing.md),
              for (var index = 0; index < workouts.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _WorkoutHistoryCard(
                    workout: workouts[index],
                    index: index,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _WorkoutHistoryCard extends StatelessWidget {
  final WorkoutModel workout;
  final int index;

  const _WorkoutHistoryCard({
    required this.workout,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy · HH:mm');
    final exerciseName = workout.exercises.isEmpty
        ? 'Workout'
        : workout.exercises.first.exerciseType.displayName;
    final color = [
      AppColors.accent,
      AppColors.turquoise,
      AppColors.pink,
    ][index % 3];

    return PremiumCard(
      onTap: () => context.pushNamed(
        RouteNames.workoutDetail,
        pathParameters: {'id': workout.id},
      ),
      child: Row(
        children: [
          GlassIconBadge(
            icon: Icons.fitness_center_rounded,
            color: color,
            size: 52,
            iconSize: 23,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(exerciseName, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dateFormat.format(workout.date),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 6),
                Text(
                  '${workout.exercises.length} exercise'
                  '${workout.exercises.length == 1 ? '' : 's'} · '
                  '${workout.durationSeconds ~/ 60} min',
                  style: AppTextStyles.cardMeta,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${workout.totalXpEarned}',
                style: AppTextStyles.goldValue,
              ),
              Text('XP', style: AppTextStyles.goldLabelSmall),
              const SizedBox(height: AppSpacing.sm),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textDimmed,
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
