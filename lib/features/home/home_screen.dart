import 'package:fitquest_rpg/core/routing/route_names.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const HomeScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider).valueOrNull;
    final displayName = user?.name ?? 'Warrior';
    final title = user?.title.isNotEmpty == true ? user!.title : 'Rising Hero';
    final level = user?.level ?? 1;
    final streak = user?.streak ?? 0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                borderRadius: BorderRadius.circular(24),
                child: Row(
                  children: [
                    Semantics(
                      button: true,
                      label: 'Open profile',
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => context.pushNamed(RouteNames.profile),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: AppColors.coolGradient,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.glassHighlight,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x4D6366F1),
                                blurRadius: 18,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.turquoise,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.turquoise,
                                      blurRadius: 7,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'FITQUEST',
                                style: AppTextStyles.pillLabel.copyWith(
                                  color: AppColors.textPrimary,
                                  letterSpacing: 1.4,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Lv.$level $displayName · $title',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    GlassPill(
                      icon: streak > 0
                          ? Icons.local_fire_department_rounded
                          : Icons.bolt_rounded,
                      label: streak > 0 ? '${streak}D' : 'READY',
                      color: streak > 0 ? AppColors.gold : AppColors.turquoise,
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: navigationShell),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: GlassContainer(
                padding: const EdgeInsets.all(5),
                borderRadius: BorderRadius.circular(30),
                child: Row(
                  children: [
                    _TabItem(
                      index: 0,
                      current: navigationShell.currentIndex,
                      icon: Icons.grid_view_rounded,
                      label: 'Home',
                      onTap: () => _openBranch(0),
                    ),
                    _TabItem(
                      index: 1,
                      current: navigationShell.currentIndex,
                      icon: Icons.fitness_center_rounded,
                      label: 'Train',
                      onTap: () => _openBranch(1),
                    ),
                    _TabItem(
                      index: 2,
                      current: navigationShell.currentIndex,
                      icon: Icons.auto_awesome_rounded,
                      label: 'Skills',
                      onTap: () => _openBranch(2),
                    ),
                    _TabItem(
                      index: 3,
                      current: navigationShell.currentIndex,
                      icon: Icons.radar_rounded,
                      label: 'Stats',
                      onTap: () => _openBranch(3),
                    ),
                    _TabItem(
                      index: 4,
                      current: navigationShell.currentIndex,
                      icon: Icons.workspace_premium_rounded,
                      label: 'Awards',
                      onTap: () => _openBranch(4),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}

class _TabItem extends StatelessWidget {
  final int index;
  final int current;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _TabItem({
    required this.index,
    required this.current,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final selected = current == index;
    return Expanded(
      child: Semantics(
        selected: selected,
        button: true,
        label: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: AnimatedContainer(
            duration: AppSpacing.standard,
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0x3D6366F1), Color(0x1FEC4899)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(24),
              border:
                  selected ? Border.all(color: const Color(0x526366F1)) : null,
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color(0x3D6366F1),
                        blurRadius: 14,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color:
                      selected ? AppColors.textPrimary : AppColors.textDimmed,
                  size: 20,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: AppTextStyles.tabLabel.copyWith(
                    color:
                        selected ? AppColors.textPrimary : AppColors.textDimmed,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
