import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/character_creation_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/workout/presentation/screens/workout_selection_screen.dart';
import '../../features/skills/presentation/screens/skill_tree_screen.dart';
import '../../features/stats/presentation/screens/character_stat_screen.dart';
import '../../features/achievements/presentation/screens/achievement_screen.dart';
import '../../features/workout/presentation/screens/active_workout_screen.dart';
import '../../features/workout/presentation/screens/workout_complete_screen.dart';
import '../../features/workout/presentation/screens/workout_history_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/skills/presentation/screens/skill_detail_screen.dart';
import '../../features/quests/presentation/screens/quest_screen.dart';
import '../../features/boss/presentation/screens/boss_list_screen.dart';
import '../../features/boss/presentation/screens/boss_battle_screen.dart';
import '../../features/boss/presentation/screens/boss_victory_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (_, __) => const CharacterCreationScreen(),
    ),

    // Main Aurora Glass shell with five persistent branches.
    StatefulShellRoute.indexedStack(
      builder: (_, __, navigationShell) =>
          HomeScreen(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/dashboard',
            name: 'dashboard',
            builder: (_, __) => const DashboardScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/workout',
            name: 'workout',
            builder: (_, __) => const WorkoutSelectionScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/skills',
            name: 'skills',
            builder: (_, __) => const SkillTreeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/stats',
            name: 'stats',
            builder: (_, __) => const CharacterStatScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home/achievements',
            name: 'achievements',
            builder: (_, __) => const AchievementScreen(),
          ),
        ]),
      ],
    ),

    // Fullscreen routes (no bottom nav)
    GoRoute(
      path: '/workout/active/:exerciseName',
      name: 'activeWorkout',
      builder: (_, state) => ActiveWorkoutScreen(
          exerciseName: state.pathParameters['exerciseName']!),
    ),
    GoRoute(
      path: '/workout/complete',
      name: 'workoutComplete',
      builder: (_, state) => WorkoutCompleteScreen(
        xp: int.tryParse(state.uri.queryParameters['xp'] ?? '0') ?? 0,
        duration:
            int.tryParse(state.uri.queryParameters['duration'] ?? '0') ?? 0,
        sets: int.tryParse(state.uri.queryParameters['sets'] ?? '0') ?? 0,
        reps: int.tryParse(state.uri.queryParameters['reps'] ?? '0') ?? 0,
        trackingLabel:
            state.uri.queryParameters['trackingLabel'] ?? 'Repetitions',
        trackingUnit: state.uri.queryParameters['trackingUnit'] ?? 'REPS',
        exercise: state.uri.queryParameters['exercise'] ?? '',
      ),
    ),
    GoRoute(
      path: '/workout/history',
      name: 'workoutHistory',
      builder: (_, __) => const WorkoutHistoryScreen(),
    ),
    GoRoute(
      path: '/workout/:id',
      name: 'workoutDetail',
      builder: (_, state) =>
          WorkoutDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/skills/:id',
      name: 'skillDetail',
      builder: (_, state) => SkillDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/quests',
      name: 'quests',
      builder: (_, __) => const QuestScreen(),
    ),
    GoRoute(
      path: '/boss',
      name: 'bossList',
      builder: (_, __) => const BossListScreen(),
    ),
    GoRoute(
      path: '/boss/:id',
      name: 'bossBattle',
      builder: (_, state) => BossBattleScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/boss/:id/victory',
      name: 'bossVictory',
      builder: (_, state) => BossVictoryScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (_, __) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/profile/settings',
      name: 'settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);
