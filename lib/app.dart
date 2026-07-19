import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/colors.dart';
import 'core/theme/glass_container.dart';
import 'core/theme/spacing.dart';
import 'core/theme/text_styles.dart';

class FitQuestApp extends ConsumerWidget {
  const FitQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      fontFamilyFallback: AppTextStyles.fontFallback,
    );

    return MaterialApp.router(
      title: 'FitQuest RPG',
      debugShowCheckedModeBanner: false,
      builder: (context, child) => AuroraBackground(
        child: child ?? const SizedBox.shrink(),
      ),
      theme: base.copyWith(
        scaffoldBackgroundColor: Colors.transparent,
        canvasColor: Colors.transparent,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          secondary: AppColors.turquoise,
          tertiary: AppColors.pink,
          surface: AppColors.surface,
          error: AppColors.danger,
          onPrimary: AppColors.textPrimary,
          onSecondary: AppColors.textInverse,
          onSurface: AppColors.textPrimary,
          onError: AppColors.textPrimary,
        ),
        textTheme: TextTheme(
          displayLarge: AppTextStyles.display,
          headlineLarge: AppTextStyles.heading1,
          headlineMedium: AppTextStyles.heading2,
          titleLarge: AppTextStyles.heading2,
          titleMedium: AppTextStyles.heading3,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.body,
          bodySmall: AppTextStyles.caption,
          labelLarge: AppTextStyles.buttonLabel,
          labelMedium: AppTextStyles.pillLabel,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 20,
          toolbarHeight: 64,
          titleTextStyle: AppTextStyles.heading3,
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
          actionsIconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        cardTheme: CardThemeData(
          color: AppColors.card,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.glassBg,
          labelStyle: AppTextStyles.caption,
          hintStyle: AppTextStyles.body.copyWith(color: AppColors.textDimmed),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            borderSide: const BorderSide(
              color: AppColors.accent,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            borderSide: const BorderSide(color: AppColors.divider),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.textPrimary,
            disabledBackgroundColor: AppColors.glassBg,
            disabledForegroundColor: AppColors.textDimmed,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.buttonBorderRadius),
              side: const BorderSide(color: AppColors.glassBorder),
            ),
            textStyle: AppTextStyles.buttonLabel,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            textStyle: AppTextStyles.buttonLabelSmall,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(AppSpacing.buttonBorderRadius),
            ),
          ),
        ),
        iconButtonTheme: IconButtonThemeData(
          style: IconButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            highlightColor: AppColors.glassStrong,
          ),
        ),
        chipTheme: base.chipTheme.copyWith(
          backgroundColor: AppColors.glassBg,
          selectedColor: AppColors.glassStrong,
          disabledColor: AppColors.glassBg,
          side: const BorderSide(color: AppColors.divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
          ),
          labelStyle: AppTextStyles.cardMeta,
          secondaryLabelStyle: AppTextStyles.cardMeta,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.textPrimary;
            }
            return AppColors.textDimmed;
          }),
          trackColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.accent.withValues(alpha: 0.62);
            }
            return AppColors.glassStrong;
          }),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.elevated,
          contentTextStyle: AppTextStyles.snackBarText,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.cardBorderRadius),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.elevated,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: AppTextStyles.heading2,
          contentTextStyle: AppTextStyles.body,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.glassBorderRadius),
            side: const BorderSide(color: AppColors.glassBorder),
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.divider,
          thickness: 1,
          space: 1,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: AppColors.accent,
          linearTrackColor: AppColors.xpBarBg,
          circularTrackColor: AppColors.xpBarBg,
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
