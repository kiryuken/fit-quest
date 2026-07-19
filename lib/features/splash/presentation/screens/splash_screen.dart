import 'dart:math' as math;

import 'package:fitquest_rpg/core/theme/colors.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/theme/spacing.dart';
import 'package:fitquest_rpg/core/theme/text_styles.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 0.65, curve: Curves.easeOut),
    );
    _scale = Tween(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final initialization = ref.read(initializationProvider);
    if (initialization is AsyncLoading) {
      final start = DateTime.now();
      while (true) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (!mounted) return;
        final state = ref.read(initializationProvider);
        if (state is! AsyncLoading) break;
        if (DateTime.now().difference(start).inSeconds > 10) break;
      }
    }

    if (!mounted) return;
    final user = ref.read(userProvider).valueOrNull;
    context.go(user == null ? '/onboarding' : '/home/dashboard');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeIn,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _controller.value * math.pi,
                            child: Container(
                              width: 174,
                              height: 174,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      AppColors.accent.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.turquoise,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.turquoise,
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 142,
                            height: 142,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.pink.withValues(alpha: 0.16),
                              ),
                            ),
                          ),
                          GlassContainer(
                            width: 112,
                            height: 112,
                            padding: EdgeInsets.zero,
                            borderRadius: BorderRadius.circular(56),
                            child: Container(
                              margin: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: AppColors.auroraGradient,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.glassHighlight,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x666366F1),
                                    blurRadius: 28,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.fitness_center_rounded,
                                size: 42,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.auroraGradient.createShader(bounds),
                  child: Text(
                    'FITQUEST',
                    style: AppTextStyles.display.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: 6,
                      fontSize: 38,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'RPG FITNESS SYSTEM',
                  style: AppTextStyles.sectionTitle.copyWith(
                    color: AppColors.turquoise,
                    letterSpacing: 2.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: 132,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return LiquidProgressBar(
                        value: _controller.value,
                        height: 5,
                        color: AppColors.accent,
                        endColor: AppColors.turquoise,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('INITIALIZING YOUR QUEST', style: AppTextStyles.pillLabel),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
