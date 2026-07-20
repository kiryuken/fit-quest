import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkoutCompleteScreen extends ConsumerWidget {
  final int xp;
  final int duration;
  final int sets;
  final int reps;
  final String trackingLabel;
  final String trackingUnit;
  final String exercise;

  const WorkoutCompleteScreen({
    super.key,
    required this.xp,
    required this.duration,
    required this.sets,
    required this.reps,
    this.trackingLabel = 'Repetitions',
    this.trackingUnit = 'REPS',
    required this.exercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;

    return AuroraScaffold(
      title: 'Session complete',
      leading: IconButton(
        icon: const Icon(Icons.close_rounded),
        tooltip: 'Back to dashboard',
        onPressed: () => context.go('/home/dashboard'),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 152,
                    height: 152,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.16),
                      ),
                    ),
                  ),
                  Container(
                    width: 122,
                    height: 122,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.gold.withValues(alpha: 0.28),
                          AppColors.gold.withValues(alpha: 0.06),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.55),
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x52FDD835),
                          blurRadius: 38,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      size: 58,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              ShaderMask(
                shaderCallback: (bounds) =>
                    AppColors.rewardGradient.createShader(bounds),
                child: Text(
                  'Great work!',
                  style: AppTextStyles.display.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(exercise, style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Your effort has been converted into character progress.',
                style: AppTextStyles.body,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Text('REWARD BANKED', style: AppTextStyles.sectionTitle),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '+$xp XP',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.gold,
                        fontSize: 42,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      children: [
                        Expanded(
                          child: MetricTile(
                            icon: Icons.timer_outlined,
                            label: 'Duration',
                            value:
                                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                            color: AppColors.turquoise,
                          ),
                        ),
                        Expanded(
                          child: MetricTile(
                            icon: Icons.layers_rounded,
                            label: 'Sets',
                            value: '$sets',
                            color: AppColors.accent,
                          ),
                        ),
                        Expanded(
                          child: MetricTile(
                            icon: Icons.repeat_rounded,
                            label: trackingLabel,
                            value: trackingUnit == 'METERS'
                                ? '$reps m'
                                : trackingUnit == 'SETS'
                                    ? '$sets/$reps'
                                    : '$reps',
                            color: AppColors.pink,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              SizedBox(
                width: double.infinity,
                child: GradientActionButton(
                  label: 'BACK TO DASHBOARD',
                  icon: Icons.grid_view_rounded,
                  onPressed: () => context.go('/home/dashboard'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
