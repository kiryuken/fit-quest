import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/providers/achievement_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final achievements = ref.watch(achievementProvider);
    final unlocked =
        achievements.where((achievement) => achievement.unlocked).length;
    final progress =
        achievements.isEmpty ? 0.0 : unlocked / achievements.length;

    return SingleChildScrollView(
      padding: AppSpacing.shellScreenPadding,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            eyebrow: 'Trophy vault',
            title: 'Your milestones',
            subtitle: 'Proof of every threshold you have crossed.',
            trailing: GlassIconBadge(
              icon: Icons.workspace_premium_rounded,
              color: AppColors.gold,
              size: 50,
              iconSize: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 86,
                      height: 86,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 7,
                        strokeCap: StrokeCap.round,
                        color: AppColors.gold,
                        backgroundColor: AppColors.xpBarBg,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$unlocked',
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          '/${achievements.length}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: AppSpacing.xl),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Collection progress',
                          style: AppTextStyles.heading3),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        unlocked == achievements.length &&
                                achievements.isNotEmpty
                            ? 'Vault complete. Every trophy is yours.'
                            : '${achievements.length - unlocked} milestones remain locked.',
                        style: AppTextStyles.body,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      GlassPill(
                        label: '${(progress * 100).round()}% COMPLETE',
                        color: AppColors.gold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Achievement collection'),
          const SizedBox(height: AppSpacing.md),
          if (achievements.isEmpty)
            const EmptyGlassState(
              icon: Icons.workspace_premium_outlined,
              title: 'Vault unavailable',
              message: 'Achievement definitions have not loaded yet.',
            )
          else
            for (var index = 0; index < achievements.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: PremiumCard(
                  backgroundColor: achievements[index].unlocked
                      ? const Color(0x14FDD835)
                      : null,
                  child: Row(
                    children: [
                      GlassIconBadge(
                        icon: achievements[index].unlocked
                            ? Icons.emoji_events_rounded
                            : Icons.lock_outline_rounded,
                        color: achievements[index].unlocked
                            ? AppColors.gold
                            : AppColors.textDimmed,
                        size: 52,
                        iconSize: 23,
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              achievements[index].name,
                              style: AppTextStyles.cardTitle.copyWith(
                                color: achievements[index].unlocked
                                    ? AppColors.textPrimary
                                    : AppColors.textDimmed,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              achievements[index].description,
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      if (achievements[index].unlocked)
                        const GlassPill(
                          label: 'EARNED',
                          color: AppColors.turquoise,
                        )
                      else
                        Text(
                          '#${(index + 1).toString().padLeft(2, '0')}',
                          style: AppTextStyles.pillLabel.copyWith(
                            color: AppColors.textDimmed,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
