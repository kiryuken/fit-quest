import 'package:fitquest_rpg/core/constants/stat_constants.dart';
import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/core/utils/level_requirements.dart';
import 'package:fitquest_rpg/data/models/daily_quest_model.dart';
import 'package:fitquest_rpg/providers/quest_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);
    final quests = ref.watch(questProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return EmptyGlassState(
            icon: Icons.person_add_alt_1_rounded,
            title: 'No hero found',
            message: 'Create your character to begin the quest.',
            actionLabel: 'CREATE CHARACTER',
            actionIcon: Icons.arrow_forward_rounded,
            onAction: () => context.go('/onboarding'),
          );
        }
        final stats = {
          for (final stat in StatType.values) stat: user.getStatValue(stat),
        };
        return _DashboardBody(
          level: user.level,
          currentXp: user.currentXp,
          streak: user.streak,
          shields: user.streakShields,
          stats: stats,
          title: user.title,
          name: user.name,
          quests: quests,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyGlassState(
        icon: Icons.error_outline_rounded,
        title: 'Unable to load dashboard',
        message: '$error',
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final int level;
  final int currentXp;
  final int streak;
  final int shields;
  final Map<StatType, double> stats;
  final String title;
  final String name;
  final List<DailyQuestModel> quests;

  const _DashboardBody({
    required this.level,
    required this.currentXp,
    required this.streak,
    required this.shields,
    required this.stats,
    required this.title,
    required this.name,
    required this.quests,
  });

  @override
  Widget build(BuildContext context) {
    final xpForNext = LevelRequirements.xpToNextLevel(level);
    final xpProgress = xpForNext == 0 ? 0.0 : currentXp / xpForNext;
    final displayTitle = title.isNotEmpty ? title : 'Rising Hero';
    final completedQuests = quests.where((quest) => quest.isCompleted).length;

    return SingleChildScrollView(
      padding: AppSpacing.shellScreenPadding,
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            eyebrow: 'Command center',
            title: 'Ready, $name?',
            subtitle: 'Build momentum one quest at a time.',
            trailing: const GlassIconBadge(
              icon: Icons.bolt_rounded,
              color: AppColors.gold,
              size: 50,
              iconSize: 24,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          GlassContainer(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: AppColors.auroraGradient,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.glassHighlight),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x596366F1),
                            blurRadius: 24,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.textPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(displayTitle, style: AppTextStyles.heading2),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: [
                              GlassPill(label: 'LEVEL $level'),
                              GlassPill(
                                label:
                                    '$shields SHIELD${shields == 1 ? '' : 'S'}',
                                icon: Icons.shield_rounded,
                                color: AppColors.turquoise,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Text('Level progress', style: AppTextStyles.cardMeta),
                    const Spacer(),
                    Text(
                      '${(xpProgress * 100).clamp(0, 100).round()}%',
                      style: AppTextStyles.cardTitle.copyWith(
                        color: AppColors.turquoise,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LiquidProgressBar(value: xpProgress, height: 10),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text('$currentXp XP', style: AppTextStyles.caption),
                    const Spacer(),
                    Text(
                      '$xpForNext XP to Lv.${level + 1}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Attributes'),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.02,
            children: [
              for (final entry in stats.entries)
                _AttributeTile(stat: entry.key, value: entry.value),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(
            title: 'Daily quests',
            actionLabel: 'Open journal',
            onAction: () => context.pushNamed(RouteNames.quests),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (quests.isEmpty)
            const PremiumCard(
              child: Row(
                children: [
                  GlassIconBadge(
                    icon: Icons.nights_stay_rounded,
                    color: AppColors.turquoise,
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'No quests today. Your next chapter arrives tomorrow.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            PremiumCard(
              child: Row(
                children: [
                  MetricTile(
                    label: 'Completed',
                    value: '$completedQuests/${quests.length}',
                    color: AppColors.turquoise,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: LiquidProgressBar(
                      value: completedQuests / quests.length,
                      height: 10,
                      color: AppColors.turquoise,
                      endColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final quest in quests)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _QuestCard(quest: quest),
              ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Training signal'),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            child: Column(
              children: [
                for (var index = 0; index < stats.entries.length; index++) ...[
                  _StatSignal(
                    stat: stats.entries.elementAt(index).key,
                    value: stats.entries.elementAt(index).value,
                  ),
                  if (index < stats.length - 1)
                    const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          PremiumCard(
            backgroundColor: const Color(0x1F6366F1),
            child: Row(
              children: [
                const GlassIconBadge(
                  icon: Icons.local_fire_department_rounded,
                  color: AppColors.gold,
                  size: 54,
                  iconSize: 26,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streak == 0
                            ? 'Start your streak'
                            : '$streak day streak',
                        style: AppTextStyles.heading2,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        streak == 0
                            ? 'Finish one workout today to ignite it.'
                            : 'Keep the chain alive with today’s training.',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                GlassPill(
                  label: streak == 0 ? 'GO' : '${streak}D',
                  color: AppColors.gold,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Quick routes'),
          const SizedBox(height: AppSpacing.md),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.9,
            children: [
              _QuickRoute(
                icon: Icons.fitness_center_rounded,
                label: 'Train',
                detail: 'Start workout',
                color: AppColors.accent,
                onTap: () => context.goNamed(RouteNames.workout),
              ),
              _QuickRoute(
                icon: Icons.auto_awesome_rounded,
                label: 'Skills',
                detail: 'Learn moves',
                color: AppColors.turquoise,
                onTap: () => context.goNamed(RouteNames.skills),
              ),
              _QuickRoute(
                icon: Icons.shield_rounded,
                label: 'Bosses',
                detail: 'Enter arena',
                color: AppColors.danger,
                onTap: () => context.pushNamed(RouteNames.bossList),
              ),
              _QuickRoute(
                icon: Icons.person_rounded,
                label: 'Profile',
                detail: 'View record',
                color: AppColors.gold,
                onTap: () => context.pushNamed(RouteNames.profile),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          GradientActionButton(
            label: 'VIEW FULL CHARACTER STATS',
            icon: Icons.radar_rounded,
            onPressed: () => context.goNamed(RouteNames.stats),
          ),
        ],
      ),
    );
  }
}

class _AttributeTile extends StatelessWidget {
  final StatType stat;
  final double value;

  const _AttributeTile({required this.stat, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStat(stat.name);
    return Semantics(
      label: '${stat.displayName}: ${value.toStringAsFixed(1)}',
      child: PremiumCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: color, blurRadius: 7),
                    ],
                  ),
                ),
                const Spacer(),
                Text(stat.shortName, style: AppTextStyles.statGridLabel),
              ],
            ),
            Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.statValue.copyWith(
                color: color,
                fontSize: 23,
              ),
            ),
            Text(
              stat.displayName,
              style: AppTextStyles.caption.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestCard extends StatelessWidget {
  final DailyQuestModel quest;

  const _QuestCard({required this.quest});

  @override
  Widget build(BuildContext context) {
    final progress = quest.target == 0 ? 0.0 : quest.progress / quest.target;
    final color = quest.isCompleted ? AppColors.turquoise : AppColors.accent;
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GlassIconBadge(
            icon: quest.isCompleted ? Icons.check_rounded : Icons.flag_rounded,
            color: color,
            size: 42,
            iconSize: 19,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        quest.title,
                        style: AppTextStyles.cardTitle.copyWith(
                          color: quest.isCompleted
                              ? AppColors.textDimmed
                              : AppColors.textPrimary,
                          decoration: quest.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Text(
                      '+${quest.expReward} XP',
                      style: AppTextStyles.xpGain,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                LiquidProgressBar(
                  value: progress,
                  height: 5,
                  color: color,
                  endColor:
                      quest.isCompleted ? AppColors.accent : AppColors.pink,
                ),
                const SizedBox(height: 6),
                Text(
                  '${quest.progress} / ${quest.target}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatSignal extends StatelessWidget {
  final StatType stat;
  final double value;

  const _StatSignal({required this.stat, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStat(stat.name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(stat.displayName, style: AppTextStyles.cardMeta),
            const Spacer(),
            Text(
              value.toStringAsFixed(1),
              style: AppTextStyles.cardTitle.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 7),
        LiquidProgressBar(
          value: value / StatConstants.maxStatCap,
          height: 5,
          color: color,
          endColor: color,
        ),
      ],
    );
  }
}

class _QuickRoute extends StatelessWidget {
  final IconData icon;
  final String label;
  final String detail;
  final Color color;
  final VoidCallback onTap;

  const _QuickRoute({
    required this.icon,
    required this.label,
    required this.detail,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GlassIconBadge(
            icon: icon,
            color: color,
            size: 42,
            iconSize: 19,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.cardTitle),
                Text(
                  detail,
                  style: AppTextStyles.caption.copyWith(fontSize: 10),
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
