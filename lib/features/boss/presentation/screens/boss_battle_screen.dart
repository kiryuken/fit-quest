import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/boss_battle_model.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BossBattleScreen extends ConsumerStatefulWidget {
  final String id;

  const BossBattleScreen({super.key, required this.id});

  @override
  ConsumerState<BossBattleScreen> createState() => _BossBattleScreenState();
}

class _BossBattleScreenState extends ConsumerState<BossBattleScreen> {
  bool _battling = false;
  String _log = '';

  Future<void> _attack() async {
    final user = ref.read(userProvider).valueOrNull;
    if (user == null) return;

    final bossRepository = ref.read(bossRepositoryProvider);
    final boss = await bossRepository.getBoss(widget.id);
    if (boss == null || boss.isDefeated) return;

    setState(() => _battling = true);
    final totalStats = user.stats.values.fold(0, (a, b) => a + b);
    final averageStat = totalStats / user.stats.length;
    final playerDamage = (averageStat * 2).round().clamp(5, 200);
    final bossDamage = (boss.level * boss.difficulty * 3).clamp(3, 100);

    await Future.delayed(const Duration(milliseconds: 600));
    final newDamage = boss.currentDamageDone + playerDamage;
    final defeated = newDamage >= boss.hp;

    if (defeated) {
      await bossRepository.saveBoss(
        boss.copyWith(
          currentDamageDone: boss.hp,
          isDefeated: true,
        ),
      );
      await ref.read(userProvider.notifier).completeBossVictory(
            xpReward: boss.xpReward,
            statRewards: boss.statRewards.map(
              (index, value) => MapEntry(
                index < StatType.values.length
                    ? StatType.values[index]
                    : StatType.strength,
                value,
              ),
            ),
          );

      if (!mounted) return;
      setState(() {
        _log = 'Critical hit · $playerDamage damage\n'
            '${boss.name} defeated · +${boss.xpReward} XP';
        _battling = false;
      });
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      context.pushNamed(
        RouteNames.bossVictory,
        pathParameters: {'id': widget.id},
      );
    } else {
      await bossRepository.saveBoss(
        boss.copyWith(currentDamageDone: newDamage),
      );
      if (!mounted) return;
      setState(() {
        _log = 'You dealt $playerDamage damage\n'
            '${boss.name} countered for $bossDamage\n'
            '${boss.hp - newDamage} boss HP remains';
        _battling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BossBattleModel?>(
      future: ref.read(bossRepositoryProvider).getBoss(widget.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AuroraScaffold(
            title: 'Boss battle',
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final boss = snapshot.data;
        if (boss == null) {
          return const AuroraScaffold(
            title: 'Boss battle',
            body: EmptyGlassState(
              icon: Icons.search_off_rounded,
              title: 'Boss not found',
              message: 'This opponent has left the arena.',
            ),
          );
        }

        final hpRemaining =
            (boss.hp - boss.currentDamageDone).clamp(0, boss.hp);
        final hpProgress = boss.hp == 0 ? 0.0 : hpRemaining / boss.hp;
        final tierColor = Color(boss.tier.colorValue);

        return AuroraScaffold(
          title: 'Battle arena',
          body: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 36),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              GlassPill(
                                icon: Icons.shield_rounded,
                                label: boss.tier.displayName.toUpperCase(),
                                color: tierColor,
                              ),
                              const Spacer(),
                              GlassPill(
                                icon: Icons.bolt_rounded,
                                label: '${boss.xpReward} XP',
                                color: AppColors.gold,
                              ),
                            ],
                          ),
                          const Spacer(),
                          GlassContainer(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              children: [
                                Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: 184,
                                      height: 184,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.danger
                                              .withValues(alpha: 0.13),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 148,
                                      height: 148,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.danger
                                                .withValues(alpha: 0.25),
                                            AppColors.pink
                                                .withValues(alpha: 0.05),
                                          ],
                                        ),
                                        border: Border.all(
                                          color: AppColors.danger
                                              .withValues(alpha: 0.55),
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Color(0x52EF5350),
                                            blurRadius: 38,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.shield_rounded,
                                        size: 72,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text(boss.name, style: AppTextStyles.heading1),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'Level ${boss.level} · Difficulty ${boss.difficulty}',
                                  style: AppTextStyles.body.copyWith(
                                    color: tierColor,
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Row(
                                  children: [
                                    Text(
                                      'BOSS HP',
                                      style: AppTextStyles.sectionTitle,
                                    ),
                                    const Spacer(),
                                    Text(
                                      '$hpRemaining / ${boss.hp}',
                                      style: AppTextStyles.cardTitle.copyWith(
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                LiquidProgressBar(
                                  value: hpProgress,
                                  height: 12,
                                  color: AppColors.danger,
                                  endColor: AppColors.pink,
                                ),
                              ],
                            ),
                          ),
                          if (_log.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.lg),
                            PremiumCard(
                              backgroundColor: const Color(0x146366F1),
                              child: Row(
                                children: [
                                  const GlassIconBadge(
                                    icon: Icons.receipt_long_rounded,
                                    color: AppColors.turquoise,
                                    size: 42,
                                    iconSize: 18,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      _log,
                                      style: AppTextStyles.cardMeta,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Spacer(),
                          const SizedBox(height: AppSpacing.xl),
                          SizedBox(
                            width: double.infinity,
                            child: GradientActionButton(
                              label: _battling ? 'STRIKING...' : 'ATTACK',
                              icon: Icons.flash_on_rounded,
                              loading: _battling,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.danger, AppColors.pink],
                              ),
                              onPressed: _battling ? null : _attack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
