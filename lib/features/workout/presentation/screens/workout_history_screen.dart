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

class WorkoutHistoryScreen extends ConsumerStatefulWidget {
  const WorkoutHistoryScreen({super.key});

  @override
  ConsumerState<WorkoutHistoryScreen> createState() =>
      _WorkoutHistoryScreenState();
}

class _WorkoutHistoryScreenState extends ConsumerState<WorkoutHistoryScreen> {
  static const _pageSize = 20;
  final List<WorkoutModel> _workouts = [];
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadMore);
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref.read(workoutRepositoryProvider).getWorkouts(
            beforeDate: _workouts.isEmpty ? null : _workouts.last.date,
            beforeId: _workouts.isEmpty ? null : _workouts.last.id,
            limit: _pageSize,
          );
      if (!mounted) return;
      setState(() {
        _workouts.addAll(page);
        _hasMore = page.length == _pageSize;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuroraScaffold(
      title: 'Workout history',
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _workouts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _workouts.isEmpty) {
      return EmptyGlassState(
        icon: Icons.error_outline_rounded,
        title: 'History unavailable',
        message: '$_error',
        actionLabel: 'RETRY',
        actionIcon: Icons.refresh_rounded,
        onAction: _loadMore,
      );
    }
    if (_workouts.isEmpty) {
      return const EmptyGlassState(
        icon: Icons.history_rounded,
        title: 'No sessions yet',
        message: 'Complete your first workout and it will appear here.',
      );
    }

    final loadedXp = _workouts.fold<int>(
      0,
      (sum, workout) => sum + workout.totalXpEarned,
    );
    return ListView.builder(
      padding: AppSpacing.screenPadding,
      physics: const BouncingScrollPhysics(),
      itemCount: _workouts.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: PageHeader(
              eyebrow: 'Training archive',
              title: '${_workouts.length} loaded sessions',
              subtitle: 'History is retained locally and loaded 20 at a time.',
              trailing: GlassPill(
                icon: Icons.bolt_rounded,
                label: '$loadedXp XP',
                color: AppColors.gold,
              ),
            ),
          );
        }
        final workoutIndex = index - 1;
        if (workoutIndex < _workouts.length) {
          if (workoutIndex >= _workouts.length - 4) {
            Future.microtask(_loadMore);
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _WorkoutHistoryCard(
              workout: _workouts[workoutIndex],
              index: workoutIndex,
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Center(
            child: _loading
                ? const CircularProgressIndicator()
                : _error != null
                    ? TextButton.icon(
                        onPressed: _loadMore,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Retry loading more'),
                      )
                    : Text(
                        _hasMore ? '' : 'Entire local history loaded',
                        style: AppTextStyles.caption,
                      ),
          ),
        );
      },
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
    final sessionName = workout.exercises.isEmpty
        ? 'Workout'
        : workout.exercises.map((exercise) => exercise.displayName).join(' · ');
    final color = const [
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
                Text(
                  sessionName,
                  style: AppTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  dateFormat.format(workout.date),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: 6),
                Text(
                  '${workout.validSetCount}/${workout.plannedSetCount} sets · '
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
              if (workout.personalRecordMovementIds.isNotEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: AppSpacing.sm),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: 18,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
