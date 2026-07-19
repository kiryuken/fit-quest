import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/providers/game_reset_provider.dart';
import 'package:fitquest_rpg/providers/settings_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() {
    _notificationsEnabled =
        ref.read(settingsPreferencesProvider).notificationsEnabled;
  }

  Future<void> _toggleNotifications(bool value) async {
    await ref.read(settingsPreferencesProvider).setNotificationsEnabled(value);
    if (!mounted) return;
    setState(() => _notificationsEnabled = value);
  }

  Future<void> _resetData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.danger,
          size: 34,
        ),
        title: const Text('Reset all data?'),
        content: const Text(
          'This permanently deletes your character, workout history, '
          'skill progress, bosses, and local settings. This action cannot '
          'be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('DELETE EVERYTHING'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await ref.read(gameResetServiceProvider).resetAllData();

    if (!mounted) return;
    // Root messenger survives navigation, so the confirmation stays visible.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All local data has been reset.')),
    );
    context.go('/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return AuroraScaffold(
      title: 'Settings',
      body: ListView(
        padding: AppSpacing.screenPadding,
        physics: const BouncingScrollPhysics(),
        children: [
          const PageHeader(
            eyebrow: 'System controls',
            title: 'Tune your experience',
            subtitle: 'Personalize how FitQuest behaves on this device.',
            trailing: GlassIconBadge(
              icon: Icons.tune_rounded,
              color: AppColors.accent,
              size: 50,
              iconSize: 23,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Appearance'),
          const SizedBox(height: AppSpacing.md),
          const _SettingsGroup(
            children: [
              _SettingSwitch(
                icon: Icons.auto_awesome_rounded,
                color: AppColors.accent,
                title: 'Aurora dark',
                subtitle: 'The current visual experience',
                value: true,
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Notifications'),
          const SizedBox(height: AppSpacing.md),
          _SettingsGroup(
            children: [
              _SettingSwitch(
                icon: Icons.notifications_active_rounded,
                color: AppColors.turquoise,
                title: 'Workout reminders',
                subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(title: 'Feedback'),
          const SizedBox(height: AppSpacing.md),
          const _SettingsGroup(
            children: [
              _SettingSwitch(
                icon: Icons.volume_up_rounded,
                color: AppColors.pink,
                title: 'Sound effects',
                subtitle: 'Coming in a future update',
                value: false,
                enabled: false,
              ),
              _SettingSwitch(
                icon: Icons.vibration_rounded,
                color: AppColors.gold,
                title: 'Haptic feedback',
                subtitle: 'Coming in a future update',
                value: false,
                enabled: false,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(
            title: 'Danger zone',
            actionLabel: 'Permanent',
            onAction: null,
          ),
          const SizedBox(height: AppSpacing.md),
          PremiumCard(
            onTap: _resetData,
            backgroundColor: const Color(0x14EF5350),
            child: Row(
              children: [
                const GlassIconBadge(
                  icon: Icons.delete_forever_rounded,
                  color: AppColors.danger,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reset all data',
                        style: AppTextStyles.cardTitle.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Delete your character and all progress',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.danger,
                  size: 15,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;

  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Divider(),
              ),
          ],
        ],
      ),
    );
  }
}

class _SettingSwitch extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;

  const _SettingSwitch({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            GlassIconBadge(
              icon: icon,
              color: color,
              size: 44,
              iconSize: 20,
            ),
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
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
            ),
          ],
        ),
      ),
    );
  }
}
