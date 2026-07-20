import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/skill_model.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/data/skill_catalog.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SkillDetailScreen extends ConsumerWidget {
  final String id;

  const SkillDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = SkillCatalog.allSkills();
    final skill = catalog.firstWhere(
      (item) => item.id == id,
      orElse: () => catalog.first,
    );
    final user = ref.watch(userProvider).valueOrNull;
    final unlocked = user?.hasSkill(skill.id) ?? false;
    final currentLevel = user?.skillLevel(skill.id) ?? 0;
    final stats = {
      if (user != null)
        for (final stat in StatType.values) stat: user.getStatValue(stat),
    };
    final color = _colorForArt(skill.martialArtIndex);

    return AuroraScaffold(
      title: skill.name,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: AppSpacing.screenPadding,
            sliver: SliverList.list(
              children: [
                GlassContainer(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassIconBadge(
                            icon: Icons.sports_martial_arts_rounded,
                            color: color,
                            size: 62,
                            iconSize: 29,
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(skill.name, style: AppTextStyles.heading2),
                                const SizedBox(height: AppSpacing.sm),
                                Wrap(
                                  spacing: AppSpacing.sm,
                                  runSpacing: AppSpacing.sm,
                                  children: [
                                    GlassPill(
                                      label: skill.martialArt.displayName,
                                      color: color,
                                    ),
                                    GlassPill(
                                      label: skill.category.displayName,
                                      color: AppColors.pink,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(skill.description, style: AppTextStyles.body),
                      const SizedBox(height: AppSpacing.xl),
                      Row(
                        children: [
                          GlassPill(
                            icon: unlocked
                                ? Icons.check_circle_rounded
                                : Icons.lock_outline_rounded,
                            label: unlocked ? 'LEVEL $currentLevel' : 'LOCKED',
                            color: unlocked
                                ? AppColors.turquoise
                                : AppColors.textDimmed,
                          ),
                          const Spacer(),
                          Text(
                            'MAX LV.${skill.maxLevel}',
                            style: AppTextStyles.pillLabel,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      LiquidProgressBar(
                        value: currentLevel / skill.maxLevel,
                        height: 7,
                        color: color,
                        endColor: AppColors.turquoise,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Prerequisites'),
                const SizedBox(height: AppSpacing.md),
                PremiumCard(
                  child: Column(
                    children: _prerequisiteRows(
                      skill: skill,
                      user: user,
                      stats: stats,
                      unlocked: unlocked,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SectionHeader(title: 'Level progression'),
                const SizedBox(height: AppSpacing.md),
                for (var level = 1; level <= skill.maxLevel; level++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _LevelCard(
                      level: level,
                      skill: skill,
                      currentLevel: currentLevel,
                      color: color,
                    ),
                  ),
                if (!unlocked) ...[
                  const SizedBox(height: AppSpacing.xl),
                  GradientActionButton(
                    label: 'UNLOCK TECHNIQUE',
                    icon: Icons.lock_open_rounded,
                    onPressed: () async {
                      await ref
                          .read(userProvider.notifier)
                          .unlockSkill(skill.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${skill.name} unlocked!')),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _prerequisiteRows({
    required SkillModel skill,
    required UserModel? user,
    required Map<StatType, double> stats,
    required bool unlocked,
  }) {
    final rows = <Widget>[];
    if (skill.prerequisites.isEmpty) {
      rows.add(
        const _PrerequisiteRow(
          label: 'Foundation technique — no prior skill required',
          met: true,
        ),
      );
    } else {
      for (final prerequisiteId in skill.prerequisites) {
        rows.add(
          _PrerequisiteRow(
            label: 'Master ${_skillName(prerequisiteId)}',
            met: unlocked || (user?.hasSkill(prerequisiteId) ?? false),
          ),
        );
      }
    }

    if (!unlocked) {
      final firstLevel = skill.levelData(1);
      if (firstLevel != null) {
        for (final requirement in firstLevel.statRequirements.entries) {
          final stat = StatType.values[requirement.key];
          rows.add(
            _PrerequisiteRow(
              label: '${stat.displayName} ${requirement.value}+',
              met: (stats[stat] ?? 0) >= requirement.value,
            ),
          );
        }
        for (final exercise in firstLevel.exerciseRequirements) {
          rows.add(
            _PrerequisiteRow(
              label: '${exercise.totalRequired} related exercise reps',
              met: false,
            ),
          );
        }
      }
    }

    return [
      for (var index = 0; index < rows.length; index++) ...[
        rows[index],
        if (index < rows.length - 1)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(),
          ),
      ],
    ];
  }

  String _skillName(String skillId) {
    final catalog = SkillCatalog.allSkills();
    return catalog
        .firstWhere(
          (skill) => skill.id == skillId,
          orElse: () => catalog.first,
        )
        .name;
  }

  Color _colorForArt(int index) => const [
        AppColors.accent,
        AppColors.turquoise,
        AppColors.danger,
        AppColors.pink,
        AppColors.gold,
      ][index % 5];
}

class _PrerequisiteRow extends StatelessWidget {
  final String label;
  final bool met;

  const _PrerequisiteRow({required this.label, required this.met});

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.turquoise : AppColors.textDimmed;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.35)),
          ),
          child: Icon(
            met ? Icons.check_rounded : Icons.lock_outline_rounded,
            color: color,
            size: 15,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.cardMeta.copyWith(
              color: met ? AppColors.textSecondary : AppColors.textDimmed,
            ),
          ),
        ),
        Text(
          met ? 'MET' : 'OPEN',
          style: AppTextStyles.pillLabel.copyWith(color: color),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final SkillModel skill;
  final int currentLevel;
  final Color color;

  const _LevelCard({
    required this.level,
    required this.skill,
    required this.currentLevel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final data = skill.levelData(level);
    final isUnlocked = currentLevel >= level;
    final isCurrent = currentLevel == level;
    final statusColor = isUnlocked ? color : AppColors.textDimmed;

    return PremiumCard(
      backgroundColor: isCurrent ? color.withValues(alpha: 0.1) : null,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.45),
                        color.withValues(alpha: 0.12),
                      ],
                    )
                  : null,
              color: isUnlocked ? null : AppColors.glassBg,
              shape: BoxShape.circle,
              border: Border.all(
                color: statusColor.withValues(alpha: 0.45),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              '$level',
              style: AppTextStyles.cardTitle.copyWith(color: statusColor),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Level $level', style: AppTextStyles.cardTitle),
                    if (isCurrent) ...[
                      const SizedBox(width: AppSpacing.sm),
                      GlassPill(label: 'CURRENT', color: color),
                    ],
                  ],
                ),
                if (data != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${data.damageMultiplier}× damage · ${data.baseDamage} base',
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ),
          Icon(
            isUnlocked
                ? Icons.check_circle_rounded
                : Icons.lock_outline_rounded,
            color: statusColor,
            size: 20,
          ),
        ],
      ),
    );
  }
}
