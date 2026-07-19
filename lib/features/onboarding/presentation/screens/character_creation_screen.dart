import 'package:fitquest_rpg/core/constants/stat_constants.dart';
import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CharacterCreationScreen extends ConsumerStatefulWidget {
  const CharacterCreationScreen({super.key});

  @override
  ConsumerState<CharacterCreationScreen> createState() =>
      _CharacterCreationScreenState();
}

class _CharacterCreationScreenState
    extends ConsumerState<CharacterCreationScreen> {
  final _nameController = TextEditingController(text: 'Warrior');
  final _ageController = TextEditingController(text: '18');
  final _heightController = TextEditingController(text: '170');
  final _weightController = TextEditingController(text: '70');
  String _fitnessLevel = 'Beginner';
  StatType? _selectedFocus;
  int _bonusPoints = 5;
  bool _saving = false;

  final Map<StatType, int> _stats = StatConstants.defaultStats();
  final Map<StatType, int> _bonuses = {
    for (final stat in StatType.values) stat: 0,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _addBonus(StatType stat) {
    if (_bonusPoints <= 0) return;
    setState(() {
      _bonuses[stat] = (_bonuses[stat] ?? 0) + 1;
      _bonusPoints--;
    });
  }

  void _removeBonus(StatType stat) {
    if ((_bonuses[stat] ?? 0) <= 0) return;
    setState(() {
      _bonuses[stat] = (_bonuses[stat] ?? 0) - 1;
      _bonusPoints++;
    });
  }

  Future<void> _completeCreation() async {
    if (_saving) return;
    setState(() => _saving = true);
    final age = int.tryParse(_ageController.text) ?? 18;
    final height = double.tryParse(_heightController.text) ?? 170;
    final weight = double.tryParse(_weightController.text) ?? 70;

    try {
      await ref.read(userProvider.notifier).createCharacter(
            name: _nameController.text.trim().isEmpty
                ? 'Warrior'
                : _nameController.text.trim(),
            age: age,
            height: height,
            weight: weight,
            fitnessLevel: _fitnessLevel,
          );
      if (!mounted) return;
      context.go('/home/dashboard');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
              sliver: SliverList.list(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: AppColors.coolGradient,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.glassHighlight),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.textPrimary,
                          size: 19,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'FITQUEST',
                          style: AppTextStyles.cardTitle.copyWith(
                            letterSpacing: 1.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const GlassPill(
                        label: 'CHARACTER SETUP',
                        color: AppColors.turquoise,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  const PageHeader(
                    eyebrow: 'New game',
                    title: 'Build your hero',
                    subtitle:
                        'Set your baseline, choose a focus, and enter your first quest.',
                    trailing: GlassIconBadge(
                      icon: Icons.person_add_alt_1_rounded,
                      color: AppColors.pink,
                      size: 52,
                      iconSize: 24,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  GlassContainer(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const GlassIconBadge(
                              icon: Icons.badge_rounded,
                              color: AppColors.accent,
                              size: 44,
                              iconSize: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Hero identity',
                                style: AppTextStyles.heading3,
                              ),
                            ),
                            const GlassPill(label: '01'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        TextField(
                          controller: _nameController,
                          style: AppTextStyles.bodyLarge,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Character name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Body baseline'),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _MetricField(
                          label: 'Age',
                          suffix: 'yr',
                          controller: _ageController,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _MetricField(
                          label: 'Height',
                          suffix: 'cm',
                          controller: _heightController,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _MetricField(
                          label: 'Weight',
                          suffix: 'kg',
                          controller: _weightController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Fitness level'),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final level in const [
                        'Beginner',
                        'Intermediate',
                        'Advanced',
                      ])
                        ChoiceChip(
                          avatar: Icon(
                            _fitnessIcon(level),
                            size: 17,
                            color: _fitnessLevel == level
                                ? AppColors.turquoise
                                : AppColors.textDimmed,
                          ),
                          label: Text(level),
                          selected: _fitnessLevel == level,
                          selectedColor:
                              AppColors.turquoise.withValues(alpha: 0.16),
                          side: BorderSide(
                            color: _fitnessLevel == level
                                ? AppColors.turquoise
                                : AppColors.divider,
                          ),
                          onSelected: (_) {
                            setState(() => _fitnessLevel = level);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionHeader(title: 'Preferred focus'),
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final stat in StatType.values)
                        ChoiceChip(
                          avatar: Icon(
                            _statIcon(stat),
                            size: 17,
                            color: _selectedFocus == stat
                                ? AppColors.forStat(stat.name)
                                : AppColors.textDimmed,
                          ),
                          label: Text(stat.displayName),
                          selected: _selectedFocus == stat,
                          selectedColor: AppColors.forStat(stat.name)
                              .withValues(alpha: 0.16),
                          side: BorderSide(
                            color: _selectedFocus == stat
                                ? AppColors.forStat(stat.name)
                                : AppColors.divider,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedFocus = selected ? stat : null;
                            });
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      const Expanded(
                        child: SectionHeader(title: 'Bonus allocation'),
                      ),
                      GlassPill(
                        icon: Icons.add_rounded,
                        label: '$_bonusPoints LEFT',
                        color: _bonusPoints > 0
                            ? AppColors.gold
                            : AppColors.turquoise,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Preview how you want your starting build to feel.',
                    style: AppTextStyles.caption,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final stat in StatType.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _StatAllocationCard(
                        stat: stat,
                        value: (_stats[stat] ?? 1) + (_bonuses[stat] ?? 0),
                        hasBonus: (_bonuses[stat] ?? 0) > 0,
                        canRemove: (_bonuses[stat] ?? 0) > 0,
                        canAdd: _bonusPoints > 0,
                        onRemove: () => _removeBonus(stat),
                        onAdd: () => _addBonus(stat),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xl),
                  GradientActionButton(
                    label: 'BEGIN THE ADVENTURE',
                    icon: Icons.arrow_forward_rounded,
                    loading: _saving,
                    onPressed: _saving ? null : _completeCreation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _fitnessIcon(String level) => switch (level) {
        'Beginner' => Icons.spa_rounded,
        'Intermediate' => Icons.trending_up_rounded,
        'Advanced' => Icons.local_fire_department_rounded,
        _ => Icons.bolt_rounded,
      };

  IconData _statIcon(StatType stat) => switch (stat) {
        StatType.strength => Icons.fitness_center_rounded,
        StatType.agility => Icons.bolt_rounded,
        StatType.endurance => Icons.favorite_rounded,
        StatType.dexterity => Icons.gps_fixed_rounded,
        StatType.constitution => Icons.shield_rounded,
        StatType.intelligence => Icons.psychology_rounded,
      };
}

class _MetricField extends StatelessWidget {
  final String label;
  final String suffix;
  final TextEditingController controller;

  const _MetricField({
    required this.label,
    required this.suffix,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: AppTextStyles.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        suffixStyle: AppTextStyles.caption,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
      ),
    );
  }
}

class _StatAllocationCard extends StatelessWidget {
  final StatType stat;
  final int value;
  final bool hasBonus;
  final bool canRemove;
  final bool canAdd;
  final VoidCallback onRemove;
  final VoidCallback onAdd;

  const _StatAllocationCard({
    required this.stat,
    required this.value,
    required this.hasBonus,
    required this.canRemove,
    required this.canAdd,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forStat(stat.name);
    return PremiumCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: hasBonus ? color.withValues(alpha: 0.07) : null,
      child: Row(
        children: [
          GlassIconBadge(
            icon: _iconFor(stat),
            color: color,
            size: 44,
            iconSize: 20,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(stat.displayName, style: AppTextStyles.cardTitle),
                const SizedBox(height: AppSpacing.xs),
                Text(_description(stat), style: AppTextStyles.caption),
              ],
            ),
          ),
          _PointButton(
            icon: Icons.remove_rounded,
            color: AppColors.textDimmed,
            enabled: canRemove,
            onTap: onRemove,
          ),
          SizedBox(
            width: 44,
            child: Text(
              '$value',
              style: AppTextStyles.statValue.copyWith(
                color: hasBonus ? color : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _PointButton(
            icon: Icons.add_rounded,
            color: color,
            enabled: canAdd,
            onTap: onAdd,
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

  String _description(StatType stat) => switch (stat) {
        StatType.strength => 'Power and physical damage',
        StatType.agility => 'Speed and movement',
        StatType.endurance => 'Stamina and cardio',
        StatType.dexterity => 'Precision and technique',
        StatType.constitution => 'Durability and HP',
        StatType.intelligence => 'Strategy and analysis',
      };
}

class _PointButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _PointButton({
    required this.icon,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.3,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: enabled ? onTap : null,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.11),
            shape: BoxShape.circle,
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}
