import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/daily_quest_model.dart';
import 'package:fitquest_rpg/providers/quest_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuestScreen extends ConsumerWidget {
  const QuestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quests = ref.watch(questProvider);
    final completed = quests.where((quest) => quest.isCompleted).length;
    final completion = quests.isEmpty ? 0.0 : completed / quests.length;
    final totalReward = quests.fold<int>(
      0,
      (total, quest) => total + quest.expReward,
    );

    return AuroraScaffold(
      title: 'Quest journal',
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              eyebrow: 'Daily chapter',
              title: 'Today’s objectives',
              subtitle: 'Clear the board before the daily reset.',
              trailing: GlassIconBadge(
                icon: Icons.flag_rounded,
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
                      Expanded(
                        child: MetricTile(
                          label: 'Complete',
                          value: '$completed/${quests.length}',
                          color: AppColors.turquoise,
                        ),
                      ),
                      Expanded(
                        child: MetricTile(
                          label: 'Remaining',
                          value: '${quests.length - completed}',
                          color: AppColors.pink,
                        ),
                      ),
                      Expanded(
                        child: MetricTile(
                          label: 'Available',
                          value: '$totalReward XP',
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Text('Daily completion', style: AppTextStyles.cardMeta),
                      const Spacer(),
                      Text(
                        '${(completion * 100).round()}%',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.turquoise,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  LiquidProgressBar(
                    value: completion,
                    height: 10,
                    color: AppColors.turquoise,
                    endColor: AppColors.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const SectionHeader(title: 'Objectives'),
            const SizedBox(height: AppSpacing.md),
            if (quests.isEmpty)
              const EmptyGlassState(
                icon: Icons.nights_stay_rounded,
                title: 'Quest board is quiet',
                message: 'New objectives will appear on the next daily reset.',
              )
            else
              for (var index = 0; index < quests.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _QuestObjectiveCard(
                    quest: quests[index],
                    number: index + 1,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _QuestObjectiveCard extends StatelessWidget {
  final DailyQuestModel quest;
  final int number;

  const _QuestObjectiveCard({
    required this.quest,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    final progress = quest.target == 0 ? 0.0 : quest.progress / quest.target;
    final color = quest.isCompleted ? AppColors.turquoise : AppColors.accent;

    return PremiumCard(
      backgroundColor: quest.isCompleted ? const Color(0x142DD4BF) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              GlassIconBadge(
                icon: quest.isCompleted
                    ? Icons.check_rounded
                    : Icons.flag_rounded,
                color: color,
                size: 50,
                iconSize: 22,
              ),
              Positioned(
                right: -4,
                top: -5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: color),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$number',
                    style: AppTextStyles.pillLabel.copyWith(
                      color: color,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(width: AppSpacing.sm),
                    GlassPill(
                      icon: Icons.bolt_rounded,
                      label: '+${quest.expReward}',
                      color: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                LiquidProgressBar(
                  value: progress,
                  height: 6,
                  color: color,
                  endColor:
                      quest.isCompleted ? AppColors.accent : AppColors.pink,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${quest.progress} / ${quest.target}',
                      style: AppTextStyles.caption,
                    ),
                    const Spacer(),
                    Text(
                      quest.isCompleted ? 'CLAIMED' : 'IN PROGRESS',
                      style: AppTextStyles.pillLabel.copyWith(color: color),
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
}
