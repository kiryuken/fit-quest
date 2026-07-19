import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/boss_battle_model.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BossVictoryScreen extends ConsumerWidget {
  final String id;

  const BossVictoryScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<BossBattleModel?>(
      future: ref.read(bossRepositoryProvider).getBoss(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AuroraScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final boss = snapshot.data;
        final name = boss?.name ?? 'Boss';
        final xp = boss?.xpReward ?? 0;
        final statRewards = boss?.statRewards ?? <int, int>{};

        return AuroraScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 42, 24, 32),
              child: Column(
                children: [
                  const GlassPill(
                    icon: Icons.auto_awesome_rounded,
                    label: 'BOSS CLEARED',
                    color: AppColors.gold,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.13),
                          ),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.gold.withValues(alpha: 0.3),
                              AppColors.gold.withValues(alpha: 0.05),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.6),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x66FDD835),
                              blurRadius: 46,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.emoji_events_rounded,
                          size: 72,
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
                      'VICTORY',
                      style: AppTextStyles.display.copyWith(
                        color: AppColors.textPrimary,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '$name has been defeated.',
                    style: AppTextStyles.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'The arena recognizes your strength.',
                    style: AppTextStyles.body,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  GlassContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        Text('REWARDS', style: AppTextStyles.sectionTitle),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          children: [
                            const GlassIconBadge(
                              icon: Icons.bolt_rounded,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Experience',
                                style: AppTextStyles.cardTitle,
                              ),
                            ),
                            Text(
                              '+$xp XP',
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                        for (final reward in statRewards.entries) ...[
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: AppSpacing.md,
                            ),
                            child: Divider(),
                          ),
                          _StatReward(
                            stat: reward.key < StatType.values.length
                                ? StatType.values[reward.key]
                                : StatType.strength,
                            value: reward.value,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: GradientActionButton(
                      label: 'RETURN TO COMMAND CENTER',
                      icon: Icons.grid_view_rounded,
                      gradient: AppColors.rewardGradient,
                      foregroundColor: AppColors.textInverse,
                      onPressed: () => context.go('/home/dashboard'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatReward extends StatelessWidget {
  final StatType stat;
  final int value;

  const _StatReward({required this.stat, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStat(stat.name);
    return Row(
      children: [
        GlassIconBadge(
          icon: Icons.auto_graph_rounded,
          color: color,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(stat.displayName, style: AppTextStyles.cardTitle),
        ),
        Text(
          '+$value',
          style: AppTextStyles.heading2.copyWith(color: color),
        ),
      ],
    );
  }
}
