import 'package:fitquest_rpg/core/enums/martial_art.dart';
import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/skill_model.dart';
import 'package:fitquest_rpg/data/skill_catalog.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SkillTreeScreen extends ConsumerWidget {
  const SkillTreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).valueOrNull;
    final skills = SkillCatalog.allSkills();
    final unlockedIds = user?.unlockedSkills ?? <String>[];
    final skillLevels = user?.skillLevels ?? <String, int>{};
    final progress = skills.isEmpty ? 0.0 : unlockedIds.length / skills.length;

    return SingleChildScrollView(
      padding: AppSpacing.shellScreenPadding,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            eyebrow: 'Technique matrix',
            title: 'Master your craft',
            subtitle: 'Train your stats, open paths, and evolve each move.',
            trailing: GlassIconBadge(
              icon: Icons.auto_awesome_rounded,
              color: AppColors.pink,
              size: 50,
              iconSize: 23,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassContainer(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Row(
                  children: [
                    MetricTile(
                      label: 'Unlocked',
                      value: '${unlockedIds.length}',
                      color: AppColors.turquoise,
                    ),
                    const SizedBox(width: AppSpacing.xl),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Mastery progress',
                                style: AppTextStyles.cardMeta,
                              ),
                              const Spacer(),
                              Text(
                                '${(progress * 100).round()}%',
                                style: AppTextStyles.cardTitle.copyWith(
                                  color: AppColors.pink,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          LiquidProgressBar(value: progress, height: 9),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${skills.length - unlockedIds.length} techniques remain',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Discipline paths'),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < MartialArt.values.length; index++)
            _MartialArtSection(
              art: MartialArt.values[index],
              color: _artColor(index),
              skills: skills
                  .where(
                      (skill) => skill.martialArt == MartialArt.values[index])
                  .toList(),
              unlockedIds: unlockedIds,
              skillLevels: skillLevels,
              userStats: user?.stats ?? {},
            ),
        ],
      ),
    );
  }

  Color _artColor(int index) => const [
        AppColors.accent,
        AppColors.turquoise,
        AppColors.danger,
        AppColors.pink,
        AppColors.gold,
      ][index % 5];
}

class _MartialArtSection extends StatelessWidget {
  final MartialArt art;
  final Color color;
  final List<SkillModel> skills;
  final List<String> unlockedIds;
  final Map<String, int> skillLevels;
  final Map<int, double> userStats;

  const _MartialArtSection({
    required this.art,
    required this.color,
    required this.skills,
    required this.unlockedIds,
    required this.skillLevels,
    required this.userStats,
  });

  @override
  Widget build(BuildContext context) {
    final unlockedCount =
        skills.where((skill) => unlockedIds.contains(skill.id)).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PremiumCard(
            backgroundColor: color.withValues(alpha: 0.09),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                GlassIconBadge(
                  icon: _iconFor(art),
                  color: color,
                  size: 44,
                  iconSize: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(art.displayName, style: AppTextStyles.heading3),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        art.description,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GlassPill(
                  label: '$unlockedCount/${skills.length}',
                  color: color,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < skills.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SkillCard(
                skill: skills[index],
                accentColor: color,
                unlocked: unlockedIds.contains(skills[index].id),
                level: skillLevels[skills[index].id] ?? 0,
                userStats: userStats,
              ),
            ),
        ],
      ),
    );
  }

  IconData _iconFor(MartialArt art) => switch (art) {
        MartialArt.aikido => Icons.all_inclusive_rounded,
        MartialArt.taekwondo => Icons.sports_martial_arts_rounded,
        MartialArt.muayThai => Icons.sports_mma_rounded,
        MartialArt.capoeira => Icons.motion_photos_on_rounded,
        MartialArt.kravMaga => Icons.security_rounded,
      };
}

class _SkillCard extends ConsumerWidget {
  final SkillModel skill;
  final Color accentColor;
  final bool unlocked;
  final int level;
  final Map<int, double> userStats;

  const _SkillCard({
    required this.skill,
    required this.accentColor,
    required this.unlocked,
    required this.level,
    required this.userStats,
  });

  bool _canUnlock() {
    if (unlocked || skill.prerequisites.isNotEmpty) return false;
    final firstLevel = skill.levelData(1);
    if (firstLevel == null) return false;
    for (final requirement in firstLevel.statRequirements.entries) {
      if ((userStats[requirement.key] ?? 0) < requirement.value) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canUnlock = _canUnlock();
    final statusColor = unlocked ? AppColors.turquoise : AppColors.textDimmed;

    return PremiumCard(
      onTap: () => context.pushNamed(
        RouteNames.skillDetail,
        pathParameters: {'id': skill.id},
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: unlocked ? accentColor.withValues(alpha: 0.07) : null,
      child: Row(
        children: [
          GlassIconBadge(
            icon: unlocked
                ? Icons.auto_awesome_rounded
                : Icons.lock_outline_rounded,
            color: unlocked ? accentColor : AppColors.textDimmed,
            size: 46,
            iconSize: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.name,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: unlocked
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  unlocked
                      ? 'Level $level of ${skill.maxLevel}'
                      : skill.description,
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (unlocked && level < skill.maxLevel)
            IconButton(
              tooltip: 'Level up ${skill.name}',
              onPressed: () async {
                await ref.read(userProvider.notifier).levelUpSkill(skill.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${skill.name} reached Level ${level + 1}!'),
                  ),
                );
              },
              icon: Icon(Icons.add_circle_rounded, color: accentColor),
            )
          else if (!unlocked && canUnlock)
            FilledButton.tonal(
              onPressed: () async {
                await ref.read(userProvider.notifier).unlockSkill(skill.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${skill.name} unlocked!')),
                );
              },
              style: FilledButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: accentColor.withValues(alpha: 0.24),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                minimumSize: const Size(0, 38),
              ),
              child: Text('Unlock', style: AppTextStyles.buttonLabelSmall),
            )
          else
            Icon(
              unlocked
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: statusColor,
              size: 20,
            ),
        ],
      ),
    );
  }
}
