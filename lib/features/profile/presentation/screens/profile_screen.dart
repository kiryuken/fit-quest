import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return AuroraScaffold(
      title: 'Profile',
      actions: [
        IconButton(
          tooltip: 'Settings',
          onPressed: () => context.pushNamed(RouteNames.settings),
          icon: const Icon(Icons.tune_rounded),
        ),
        const SizedBox(width: AppSpacing.sm),
      ],
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return EmptyGlassState(
              icon: Icons.person_search_rounded,
              title: 'No profile found',
              message: 'Create a character to establish your player record.',
              actionLabel: 'CREATE CHARACTER',
              actionIcon: Icons.arrow_forward_rounded,
              onAction: () => context.go('/onboarding'),
            );
          }
          return _ProfileContent(user: user);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyGlassState(
          icon: Icons.error_outline_rounded,
          title: 'Unable to load profile',
          message: '$error',
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final UserModel user;

  const _ProfileContent({required this.user});

  @override
  Widget build(BuildContext context) {
    final title = user.title.isNotEmpty ? user.title : 'No title equipped';
    final hpProgress = user.maxHp == 0 ? 0.0 : user.currentHp / user.maxHp;

    return ListView(
      padding: AppSpacing.screenPadding,
      physics: const BouncingScrollPhysics(),
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      gradient: AppColors.auroraGradient,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.glassHighlight,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x596366F1),
                          blurRadius: 28,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.textPrimary,
                      size: 38,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: AppTextStyles.heading1),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            GlassPill(label: 'LEVEL ${user.level}'),
                            GlassPill(
                              label: title,
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
              Row(
                children: [
                  Text('Vitality', style: AppTextStyles.cardMeta),
                  const Spacer(),
                  Text(
                    '${user.currentHp} / ${user.maxHp} HP',
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.turquoise,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              LiquidProgressBar(
                value: hpProgress,
                height: 9,
                color: AppColors.turquoise,
                endColor: AppColors.accent,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Career record'),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 1.65,
          children: [
            _ProfileMetric(
              icon: Icons.fitness_center_rounded,
              label: 'Workouts',
              value: '${user.totalWorkoutsCompleted}',
              color: AppColors.accent,
            ),
            _ProfileMetric(
              icon: Icons.bolt_rounded,
              label: 'Total XP',
              value: '${user.totalXp}',
              color: AppColors.gold,
            ),
            _ProfileMetric(
              icon: Icons.local_fire_department_rounded,
              label: 'Best streak',
              value: '${user.longestStreak}d',
              color: AppColors.danger,
            ),
            _ProfileMetric(
              icon: Icons.shield_rounded,
              label: 'Boss wins',
              value: '${user.bossBattlesWon}',
              color: AppColors.pink,
            ),
            _ProfileMetric(
              icon: Icons.auto_awesome_rounded,
              label: 'Skills',
              value: '${user.unlockedSkills.length}',
              color: AppColors.turquoise,
            ),
            _ProfileMetric(
              icon: Icons.workspace_premium_rounded,
              label: 'Titles',
              value: '${user.unlockedTitles.length}',
              color: AppColors.violet,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Body profile'),
        const SizedBox(height: AppSpacing.md),
        PremiumCard(
          child: Row(
            children: [
              Expanded(
                child: MetricTile(
                  label: 'Age',
                  value: '${user.age}',
                  color: AppColors.textPrimary,
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: 'Height',
                  value: '${user.height.toStringAsFixed(0)} cm',
                  color: AppColors.turquoise,
                ),
              ),
              Expanded(
                child: MetricTile(
                  label: 'Weight',
                  value: '${user.weight.toStringAsFixed(0)} kg',
                  color: AppColors.pink,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionHeader(title: 'Account'),
        const SizedBox(height: AppSpacing.md),
        _MenuCard(
          icon: Icons.tune_rounded,
          title: 'Settings',
          subtitle: 'Notifications, feedback, and data',
          color: AppColors.accent,
          onTap: () => context.pushNamed(RouteNames.settings),
        ),
        const SizedBox(height: AppSpacing.sm),
        _MenuCard(
          icon: Icons.info_outline_rounded,
          title: 'About FitQuest RPG',
          subtitle: 'Training meets character progression',
          color: AppColors.turquoise,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProfileMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          GlassIconBadge(
            icon: icon,
            color: color,
            size: 40,
            iconSize: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: AppTextStyles.statValue.copyWith(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
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

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      onTap: onTap,
      child: Row(
        children: [
          GlassIconBadge(icon: icon, color: color),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, style: AppTextStyles.caption),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textDimmed,
            size: 15,
          ),
        ],
      ),
    );
  }
}
