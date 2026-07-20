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
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
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
            preferredFocus: _selectedFocus,
          );
      if (!mounted) return;
      context.go('/home/dashboard');
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Character could not be created: $error')),
      );
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
                  PremiumCard(
                    backgroundColor: AppColors.accent.withValues(alpha: 0.08),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const GlassIconBadge(
                          icon: Icons.auto_graph_rounded,
                          color: AppColors.turquoise,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'All five base stats begin at 10.0 and grow only '
                            'with character level, approaching a physiological '
                            'ceiling of 50 with diminishing returns.',
                            style: AppTextStyles.caption,
                          ),
                        ),
                      ],
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
        StatType.vitality => Icons.favorite_rounded,
        StatType.senses => Icons.gps_fixed_rounded,
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
