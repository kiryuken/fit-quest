import 'dart:math' as math;

import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CharacterStatScreen extends ConsumerWidget {
  const CharacterStatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const EmptyGlassState(
            icon: Icons.person_search_rounded,
            title: 'No character found',
            message: 'Create a hero before opening the stat matrix.',
          );
        }

        final stats = {
          for (final stat in StatType.values) stat: user.stats[stat.index] ?? 1,
        };
        return _StatsContent(
          level: user.level,
          name: user.name,
          stats: stats,
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyGlassState(
        icon: Icons.error_outline_rounded,
        title: 'Unable to read stats',
        message: '$error',
      ),
    );
  }
}

class _StatsContent extends StatelessWidget {
  final int level;
  final String name;
  final Map<StatType, int> stats;

  const _StatsContent({
    required this.level,
    required this.name,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final total = stats.values.fold<int>(0, (sum, value) => sum + value);
    final strongest = stats.entries.reduce(
      (current, next) => next.value > current.value ? next : current,
    );

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: AppSpacing.shellScreenPadding,
          sliver: SliverList.list(
            children: [
              PageHeader(
                eyebrow: 'Character matrix',
                title: '$name · Lv.$level',
                subtitle: 'A live readout of your physical progression.',
                trailing: GlassPill(
                  icon: Icons.auto_graph_rounded,
                  label: '$total PTS',
                  color: AppColors.turquoise,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              GlassContainer(
                padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const GlassIconBadge(
                          icon: Icons.radar_rounded,
                          color: AppColors.accent,
                          size: 44,
                          iconSize: 20,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Stat distribution',
                                style: AppTextStyles.heading3,
                              ),
                              Text(
                                'Strongest signal: ${strongest.key.displayName}',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        GlassPill(
                          label:
                              '${strongest.key.shortName} ${strongest.value}',
                          color: AppColors.forStat(strongest.key.name),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      height: 250,
                      child: CustomPaint(
                        size: const Size.square(250),
                        painter: _StatRadarPainter(stats: stats),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Attribute details'),
              const SizedBox(height: AppSpacing.md),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.42,
                children: [
                  for (final entry in stats.entries)
                    _StatDetailCard(stat: entry.key, value: entry.value),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Growth guide'),
              const SizedBox(height: AppSpacing.md),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Match your workout to the signal you want to strengthen.',
                      style: AppTextStyles.body,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const _GrowthRow(
                      icon: Icons.fitness_center_rounded,
                      label: 'STR',
                      exercise: 'Push Up · Pull Up · Deadlift',
                      color: AppColors.strengthColor,
                    ),
                    const _GrowthRow(
                      icon: Icons.flash_on_rounded,
                      label: 'AGI',
                      exercise: 'Burpees · Jump Rope · High Knees',
                      color: AppColors.agilityColor,
                    ),
                    const _GrowthRow(
                      icon: Icons.favorite_rounded,
                      label: 'END',
                      exercise: 'Running · Cycling · Plank',
                      color: AppColors.enduranceColor,
                    ),
                    const _GrowthRow(
                      icon: Icons.gps_fixed_rounded,
                      label: 'DEX',
                      exercise: 'Yoga · Jump Rope · Pull Up',
                      color: AppColors.dexterityColor,
                    ),
                    const _GrowthRow(
                      icon: Icons.shield_rounded,
                      label: 'CON',
                      exercise: 'Plank · Squat · Deadlift',
                      color: AppColors.constitutionColor,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatDetailCard extends StatelessWidget {
  final StatType stat;
  final int value;

  const _StatDetailCard({required this.stat, required this.value});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStat(stat.name);
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GlassIconBadge(
                icon: _iconFor(stat),
                color: color,
                size: 38,
                iconSize: 17,
              ),
              const Spacer(),
              Text(
                '$value',
                style: AppTextStyles.statValue.copyWith(
                  color: color,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(stat.displayName, style: AppTextStyles.cardTitle),
          const SizedBox(height: AppSpacing.sm),
          LiquidProgressBar(
            value: value / 100,
            height: 5,
            color: color,
            endColor: color,
          ),
        ],
      ),
    );
  }

  IconData _iconFor(StatType stat) => switch (stat) {
        StatType.strength => Icons.fitness_center_rounded,
        StatType.agility => Icons.bolt_rounded,
        StatType.endurance => Icons.favorite_rounded,
        StatType.dexterity => Icons.gps_fixed_rounded,
        StatType.constitution => Icons.shield_rounded,
        StatType.intelligence => Icons.psychology_rounded,
      };
}

class _GrowthRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String exercise;
  final Color color;
  final bool isLast;

  const _GrowthRow({
    required this.icon,
    required this.label,
    required this.exercise,
    required this.color,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.md),
      child: Row(
        children: [
          GlassIconBadge(
            icon: icon,
            color: color,
            size: 38,
            iconSize: 17,
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 32,
            child: Text(
              label,
              style: AppTextStyles.pillLabel.copyWith(color: color),
            ),
          ),
          Expanded(child: Text(exercise, style: AppTextStyles.caption)),
        ],
      ),
    );
  }
}

class _StatRadarPainter extends CustomPainter {
  final Map<StatType, int> stats;

  const _StatRadarPainter({required this.stats});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 34;
    const count = 6;

    for (var ring = 1; ring <= 4; ring++) {
      final path = _polygonPath(center, radius * ring / 4, count);
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.textDimmed.withValues(alpha: 0.13)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    for (var index = 0; index < count; index++) {
      final angle = (2 * math.pi * index / count) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(
        center,
        point,
        Paint()
          ..color = AppColors.textDimmed.withValues(alpha: 0.15)
          ..strokeWidth = 1,
      );

      final stat = StatType.values[index];
      final textPainter = TextPainter(
        text: TextSpan(
          text: stat.shortName,
          style: AppTextStyles.pillLabel.copyWith(
            color: AppColors.forStat(stat.name),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final labelPoint = Offset(
        center.dx + (radius + 20) * math.cos(angle),
        center.dy + (radius + 20) * math.sin(angle),
      );
      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - textPainter.width / 2,
          labelPoint.dy - textPainter.height / 2,
        ),
      );
    }

    final dataPath = Path();
    for (var index = 0; index < count; index++) {
      final stat = StatType.values[index];
      final value = ((stats[stat] ?? 1) / 100).clamp(0.12, 1.0);
      final angle = (2 * math.pi * index / count) - math.pi / 2;
      final point = Offset(
        center.dx + radius * value * math.cos(angle),
        center.dy + radius * value * math.sin(angle),
      );
      if (index == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();

    canvas.drawPath(
      dataPath,
      Paint()
        ..shader = AppColors.auroraGradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..style = PaintingStyle.fill
        ..color = AppColors.accent.withValues(alpha: 0.2),
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..color = AppColors.turquoise.withValues(alpha: 0.85)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  Path _polygonPath(Offset center, double radius, int count) {
    final path = Path();
    for (var index = 0; index < count; index++) {
      final angle = (2 * math.pi * index / count) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _StatRadarPainter oldDelegate) {
    return oldDelegate.stats != stats;
  }
}
