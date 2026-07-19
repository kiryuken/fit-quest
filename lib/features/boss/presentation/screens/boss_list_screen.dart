import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/boss_battle_model.dart';
import 'package:fitquest_rpg/data/repositories/interfaces/boss_repository.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BossListScreen extends ConsumerWidget {
  const BossListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).valueOrNull;
    final userLevel = user?.level ?? 1;
    final totalWorkouts = user?.totalWorkoutsCompleted ?? 0;
    final bossRepo = ref.watch(bossRepositoryProvider);

    return AuroraScaffold(
      title: 'Boss arena',
      body: FutureBuilder<List<BossBattleModel>>(
        future: _loadBosses(bossRepo),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final bosses = snapshot.data ?? [];
          if (bosses.isEmpty) {
            return const EmptyGlassState(
              icon: Icons.shield_outlined,
              title: 'Arena is empty',
              message: 'No opponents are available right now.',
            );
          }

          final defeated = bosses.where((boss) => boss.isDefeated).length;
          final available = bosses.where((boss) {
            return totalWorkouts >= boss.requiredWorkouts &&
                userLevel >= boss.level &&
                !boss.isDefeated;
          }).length;

          return ListView(
            padding: AppSpacing.screenPadding,
            physics: const BouncingScrollPhysics(),
            children: [
              const PageHeader(
                eyebrow: 'Challenge ladder',
                title: 'Choose your rival',
                subtitle:
                    'Turn your training into damage and claim rare rewards.',
                trailing: GlassIconBadge(
                  icon: Icons.shield_rounded,
                  color: AppColors.danger,
                  size: 50,
                  iconSize: 24,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassContainer(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Row(
                  children: [
                    Expanded(
                      child: MetricTile(
                        label: 'Defeated',
                        value: '$defeated',
                        color: AppColors.gold,
                      ),
                    ),
                    Expanded(
                      child: MetricTile(
                        label: 'Available',
                        value: '$available',
                        color: AppColors.turquoise,
                      ),
                    ),
                    Expanded(
                      child: MetricTile(
                        label: 'Hero level',
                        value: '$userLevel',
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Opponents'),
              const SizedBox(height: AppSpacing.md),
              for (final boss in bosses)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _BossCard(
                    boss: boss,
                    unlocked: totalWorkouts >= boss.requiredWorkouts &&
                        userLevel >= boss.level,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<List<BossBattleModel>> _loadBosses(
    BossRepository bossRepository,
  ) async {
    var bosses = await bossRepository.getAllBosses();
    if (bosses.isEmpty) {
      await bossRepository.seedDefaultBosses();
      bosses = await bossRepository.getAllBosses();
    }
    return bosses;
  }
}

class _BossCard extends StatelessWidget {
  final BossBattleModel boss;
  final bool unlocked;

  const _BossCard({required this.boss, required this.unlocked});

  @override
  Widget build(BuildContext context) {
    final tierColor = Color(boss.tier.colorValue);
    final remainingHp = (boss.hp - boss.currentDamageDone).clamp(0, boss.hp);
    final hpProgress = boss.hp == 0 ? 0.0 : remainingHp / boss.hp;

    return PremiumCard(
      onTap: unlocked && !boss.isDefeated
          ? () => context.pushNamed(
                RouteNames.bossBattle,
                pathParameters: {'id': boss.id},
              )
          : null,
      backgroundColor: boss.isDefeated ? const Color(0x14FDD835) : null,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassIconBadge(
                icon: boss.isDefeated
                    ? Icons.emoji_events_rounded
                    : Icons.shield_rounded,
                color: boss.isDefeated ? AppColors.gold : tierColor,
                size: 58,
                iconSize: 27,
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            boss.name,
                            style: AppTextStyles.heading3,
                          ),
                        ),
                        GlassPill(
                          label: boss.tier.displayName.toUpperCase(),
                          color: tierColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      boss.description,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          if (boss.isDefeated)
            Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.turquoise,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Defeated · reward secured',
                  style: AppTextStyles.cardMeta.copyWith(
                    color: AppColors.turquoise,
                  ),
                ),
                const Spacer(),
                Text('+${boss.xpReward} XP', style: AppTextStyles.xpGain),
              ],
            )
          else if (!unlocked)
            Row(
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  color: AppColors.textDimmed,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Requires Lv.${boss.level} and '
                    '${boss.requiredWorkouts} workouts',
                    style: AppTextStyles.caption,
                  ),
                ),
              ],
            )
          else ...[
            Row(
              children: [
                Text('HP', style: AppTextStyles.pillLabel),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: LiquidProgressBar(
                    value: hpProgress,
                    height: 7,
                    color: AppColors.danger,
                    endColor: AppColors.pink,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '$remainingHp / ${boss.hp}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                GlassPill(
                  label: 'LV.${boss.level}',
                  color: tierColor,
                ),
                const Spacer(),
                Text('+${boss.xpReward} XP', style: AppTextStyles.xpGain),
                const SizedBox(width: AppSpacing.sm),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.textDimmed,
                  size: 18,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
