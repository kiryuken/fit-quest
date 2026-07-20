import 'package:fitquest_rpg/core/data/workout_plan_catalog.dart';
import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/workout_plan_model.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/weekly_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class WorkoutSelectionScreen extends ConsumerWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(weeklyPlanProvider);
    final now = ref.watch(clockProvider).now();
    return planAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyGlassState(
        icon: Icons.error_outline_rounded,
        title: 'Training plan unavailable',
        message: '$error',
      ),
      data: (plan) => _PlanContent(plan: plan, now: now),
    );
  }
}

class _PlanContent extends ConsumerWidget {
  final WorkoutPlanModel plan;
  final DateTime now;

  const _PlanContent({
    required this.plan,
    required this.now,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = plan.dayFor(now);
    final monday = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - DateTime.monday));

    return SingleChildScrollView(
      padding: AppSpacing.shellScreenPadding,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            eyebrow: 'Weekly protocol',
            title: plan.name,
            subtitle:
                'One complete day earns one capped session reward. Movement '
                'practice builds mastery.',
            trailing: const GlassIconBadge(
              icon: Icons.calendar_month_rounded,
              color: AppColors.turquoise,
              size: 50,
              iconSize: 23,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _TodayCard(day: today),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'This week',
            actionLabel: 'History',
            onAction: () => context.pushNamed(RouteNames.workoutHistory),
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < 7; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _PlanDayCard(
                day: plan.days.firstWhere(
                  (day) => day.weekday == index + 1,
                ),
                date: monday.add(Duration(days: index)),
                now: now,
                onEdit: (day, date) => _showDayEditor(context, ref, day, date),
              ),
            ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Schedule preset'),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose how often legs appear in your recurring week.',
                  style: AppTextStyles.body,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final entry in WorkoutPlanCatalog.presetNames.entries)
                      ChoiceChip(
                        label: Text(entry.value),
                        selected: plan.presetId == entry.key,
                        onSelected: plan.presetId == entry.key
                            ? null
                            : (_) async {
                                try {
                                  await ref
                                      .read(weeklyPlanProvider.notifier)
                                      .selectPreset(entry.key);
                                } catch (error) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Schedule could not be changed: '
                                        '$error',
                                      ),
                                    ),
                                  );
                                }
                              },
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDayEditor(
    BuildContext context,
    WidgetRef ref,
    PlannedDayModel day,
    DateTime date,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Edit ${day.label}',
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  DateFormat('EEEE, d MMMM').format(date),
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                for (final exercise in day.exercises)
                  for (final variation in exercise.variations)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        '${exercise.name} · ${variation.name}',
                        style: AppTextStyles.cardTitle,
                      ),
                      subtitle: Text(
                        '${variation.targetSets} sets × '
                        '${variation.targetValue} '
                        '${exercise.trackingMetric.shortLabel.toLowerCase()}'
                        '${variation.targetLoadKg > 0 ? ' · ${variation.targetLoadKg.toStringAsFixed(1)} kg' : ''}',
                        style: AppTextStyles.caption,
                      ),
                      trailing: IconButton(
                        tooltip: 'Edit target',
                        icon: const Icon(Icons.edit_rounded),
                        onPressed: () => _editVariation(
                          sheetContext,
                          ref,
                          date,
                          day,
                          exercise,
                          variation,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editVariation(
    BuildContext context,
    WidgetRef ref,
    DateTime date,
    PlannedDayModel day,
    PlannedExerciseModel exercise,
    VariationPlanModel variation,
  ) async {
    final setsController =
        TextEditingController(text: '${variation.targetSets}');
    final valueController =
        TextEditingController(text: '${variation.targetValue}');
    final loadController =
        TextEditingController(text: '${variation.targetLoadKg}');
    try {
      final save = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('${exercise.name} · ${variation.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: setsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Target sets'),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target ${exercise.trackingMetric.displayLabel}',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: loadController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Load (kg)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Save'),
            ),
          ],
        ),
      );
      if (save != true) return;
      await ref.read(weeklyPlanProvider.notifier).updateVariation(
            targetDate: date,
            dayId: day.id,
            exerciseId: exercise.id,
            variationId: variation.id,
            targetSets: int.tryParse(setsController.text),
            targetValue: int.tryParse(valueController.text),
            targetLoadKg: double.tryParse(loadController.text),
          );
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update target: $error')),
      );
    } finally {
      setsController.dispose();
      valueController.dispose();
      loadController.dispose();
    }
  }
}

class _TodayCard extends StatelessWidget {
  final PlannedDayModel day;

  const _TodayCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const GlassPill(
                icon: Icons.today_rounded,
                label: 'TODAY',
                color: AppColors.turquoise,
              ),
              const Spacer(),
              if (day.isOptional)
                const GlassPill(
                  label: 'OPTIONAL',
                  color: AppColors.gold,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(day.label, style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            day.isRest
                ? 'Recovery preserves your scheduled streak.'
                : '${day.exercises.length} exercise families · '
                    '${day.plannedSetCount} required sets',
            style: AppTextStyles.body,
          ),
          if (!day.isRest) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final exercise in day.exercises)
                  GlassPill(
                    label: exercise.name,
                    color: AppColors.accent,
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: GradientActionButton(
                key: const Key('start-today-workout'),
                label: 'START ${day.label.toUpperCase()}',
                icon: Icons.play_arrow_rounded,
                onPressed: () => context.pushNamed(
                  RouteNames.activeWorkout,
                  pathParameters: {'exerciseName': 'today'},
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PlanDayCard extends StatelessWidget {
  final PlannedDayModel day;
  final DateTime date;
  final DateTime now;
  final void Function(PlannedDayModel day, DateTime date) onEdit;

  const _PlanDayCard({
    required this.day,
    required this.date,
    required this.now,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final dateOnly = DateTime(date.year, date.month, date.day);
    final today = DateTime(now.year, now.month, now.day);
    final isToday = dateOnly == today;
    final isFuture = dateOnly.isAfter(today);
    final color = day.isRest
        ? AppColors.textDimmed
        : isToday
            ? AppColors.turquoise
            : AppColors.accent;
    return PremiumCard(
      backgroundColor: isToday ? color.withValues(alpha: 0.09) : null,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GlassIconBadge(
            icon: day.isRest
                ? Icons.bedtime_rounded
                : Icons.fitness_center_rounded,
            color: color,
            size: 42,
            iconSize: 19,
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 44,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE').format(date).toUpperCase(),
                  style: AppTextStyles.pillLabel.copyWith(color: color),
                ),
                Text('${date.day}', style: AppTextStyles.caption),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.label, style: AppTextStyles.cardTitle),
                Text(
                  day.isRest
                      ? 'Recovery'
                      : '${day.plannedSetCount} required sets'
                          '${day.isOptional ? ' · optional' : ''}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          if (isFuture && !day.isRest)
            IconButton(
              tooltip: 'Edit future targets',
              onPressed: () => onEdit(day, date),
              icon: const Icon(Icons.tune_rounded),
            )
          else if (isToday)
            const GlassPill(label: 'NOW', color: AppColors.turquoise),
        ],
      ),
    );
  }
}
