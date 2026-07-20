import 'package:fitquest_rpg/core/data/workout_plan_catalog.dart';
import 'package:fitquest_rpg/core/enums/exercise_type.dart';
import 'package:fitquest_rpg/core/theme/glass_container.dart';
import 'package:fitquest_rpg/core/time/app_clock.dart';
import 'package:fitquest_rpg/data/datasources/hive_datasource.dart';
import 'package:fitquest_rpg/data/models/achievement_state.dart';
import 'package:fitquest_rpg/data/models/boss_battle_model.dart';
import 'package:fitquest_rpg/data/models/daily_quest_model.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/data/models/workout_model.dart';
import 'package:fitquest_rpg/data/models/workout_plan_model.dart';
import 'package:fitquest_rpg/data/repositories/implementations/boss_repository_impl.dart';
import 'package:fitquest_rpg/data/repositories/implementations/workout_repository_impl.dart';
import 'package:fitquest_rpg/features/achievements/presentation/screens/achievement_screen.dart';
import 'package:fitquest_rpg/features/boss/presentation/screens/boss_battle_screen.dart';
import 'package:fitquest_rpg/features/boss/presentation/screens/boss_list_screen.dart';
import 'package:fitquest_rpg/features/boss/presentation/screens/boss_victory_screen.dart';
import 'package:fitquest_rpg/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:fitquest_rpg/features/profile/presentation/screens/profile_screen.dart';
import 'package:fitquest_rpg/features/quests/presentation/screens/quest_screen.dart';
import 'package:fitquest_rpg/features/skills/presentation/screens/skill_detail_screen.dart';
import 'package:fitquest_rpg/features/skills/presentation/screens/skill_tree_screen.dart';
import 'package:fitquest_rpg/features/stats/presentation/screens/character_stat_screen.dart';
import 'package:fitquest_rpg/features/workout/presentation/screens/workout_complete_screen.dart';
import 'package:fitquest_rpg/features/workout/presentation/screens/workout_detail_screen.dart';
import 'package:fitquest_rpg/features/workout/presentation/screens/workout_history_screen.dart';
import 'package:fitquest_rpg/features/workout/presentation/screens/workout_selection_screen.dart';
import 'package:fitquest_rpg/providers/achievement_provider.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/quest_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:fitquest_rpg/providers/weekly_plan_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 7, 20, 18);
  final user = _user(now);
  final plan = WorkoutPlanCatalog.create(
    fitnessLevel: 'Intermediate',
    now: now,
  );
  final workout = _workout(now);
  final boss = BossBattleModel(
    id: 'boss',
    name: 'Training Rival',
    description: 'A deterministic QA opponent.',
    hp: 50,
    xpReward: 50,
    statThresholds: const {0: 5},
  );

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('dashboard and stat matrix render exact five-stat data',
      (tester) async {
    await _pump(
      tester,
      const DashboardScreen(),
      overrides: _baseOverrides(
        now: now,
        user: user,
        plan: plan,
      ),
    );
    expect(find.text('Ready, Tester?'), findsOneWidget);
    expect(find.text('LEVEL 6'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(
      tester,
      const CharacterStatScreen(),
      overrides: _baseOverrides(now: now, user: user, plan: plan),
    );
    expect(find.textContaining('Tester · Lv.6'), findsOneWidget);
    expect(find.text('Vitality'), findsWidgets);
    expect(find.text('Senses'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('weekly plan and completion summary render full sessions',
      (tester) async {
    await _pump(
      tester,
      const WorkoutSelectionScreen(),
      overrides: _baseOverrides(now: now, user: user, plan: plan),
    );
    expect(find.text('PPL × 2'), findsWidgets);
    expect(find.text('Push Day'), findsWidgets);
    expect(find.text('START PUSH DAY'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(
      tester,
      const WorkoutCompleteScreen(
        xp: 23,
        duration: 1800,
        sets: 24,
        reps: 24,
        trackingLabel: 'Completion',
        trackingUnit: 'SETS',
        exercise: 'Push Day',
      ),
      overrides: _baseOverrides(now: now, user: user, plan: plan),
    );
    expect(find.text('+23 XP'), findsOneWidget);
    expect(find.text('24/24'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('history and nested workout detail render local records',
      (tester) async {
    final repository = _FakeWorkoutRepository([workout]);
    final overrides = [
      ..._baseOverrides(now: now, user: user, plan: plan),
      workoutRepositoryProvider.overrideWithValue(repository),
    ];
    await _pump(
      tester,
      const WorkoutHistoryScreen(),
      overrides: overrides,
    );
    expect(find.text('1 loaded sessions'), findsOneWidget);
    expect(find.text('+23'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(
      tester,
      const WorkoutDetailScreen(id: 'workout'),
      overrides: overrides,
    );
    expect(find.text('SESSION OUTPUT'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.textContaining('S1 · 10 reps'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quest, achievement, and profile screens render local state',
      (tester) async {
    final overrides = _baseOverrides(now: now, user: user, plan: plan);
    await _pump(tester, const QuestScreen(), overrides: overrides);
    expect(find.text('Today’s objectives'), findsOneWidget);
    expect(find.textContaining('Complete Push Day'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(tester, const AchievementScreen(), overrides: overrides);
    expect(find.text('Your milestones'), findsOneWidget);
    expect(find.text('Awakening'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(tester, const ProfileScreen(), overrides: overrides);
    expect(find.text('Tester'), findsOneWidget);
    expect(find.text('Boss wins'), findsOneWidget);
    expect(find.text('181 cm'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skill tree and detail render canonical requirements',
      (tester) async {
    final overrides = _baseOverrides(now: now, user: user, plan: plan);
    await _pump(tester, const SkillTreeScreen(), overrides: overrides);
    expect(find.text('Master your craft'), findsOneWidget);
    expect(find.text('Aikido'), findsWidgets);
    expect(tester.takeException(), isNull);

    await _pump(
      tester,
      const SkillDetailScreen(id: 'aikido_kokyu_ho'),
      overrides: overrides,
    );
    expect(find.text('Kokyu Ho (Breathing Power)'), findsWidgets);
    expect(find.text('LOCKED'), findsOneWidget);
    expect(find.textContaining('MAX LV.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('boss list, arena, and victory render capped rewards',
      (tester) async {
    final repository = _FakeBossRepository([boss]);
    final overrides = [
      ..._baseOverrides(now: now, user: user, plan: plan),
      bossRepositoryProvider.overrideWithValue(repository),
    ];
    await _pump(tester, const BossListScreen(), overrides: overrides);
    expect(find.text('Training Rival'), findsOneWidget);
    expect(find.text('UP TO +50 XP'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(
      tester,
      const BossBattleScreen(id: 'boss'),
      overrides: overrides,
    );
    expect(find.text('Training Rival'), findsOneWidget);
    expect(find.text('ATTACK'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await _pump(
      tester,
      const BossVictoryScreen(id: 'boss'),
      overrides: overrides,
    );
    expect(find.text('VICTORY'), findsOneWidget);
    expect(find.text('+25 XP'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _pump(
  WidgetTester tester,
  Widget screen, {
  required List<Override> overrides,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 932);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: ThemeData.dark(useMaterial3: true),
        home: AuroraBackground(child: screen),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

List<Override> _baseOverrides({
  required DateTime now,
  required UserModel user,
  required WorkoutPlanModel plan,
}) {
  final quests = QuestCatalog.forDay(plan: plan, date: now);
  final achievements = AchievementCatalog.defaults().toList();
  achievements[0] = achievements[0].copyUnlocked(at: now);
  return [
    clockProvider.overrideWithValue(FixedAppClock(now)),
    userProvider.overrideWith(() => _FixedUserNotifier(user)),
    weeklyPlanProvider.overrideWith(() => _FixedPlanNotifier(plan)),
    questProvider.overrideWith(
      (ref) => QuestNotifier.forTesting(
        initialQuests: quests,
        onExpReward: (_, __) async {},
      ),
    ),
    achievementProvider.overrideWith(
      (ref) => AchievementNotifier.forTesting(
        initialAchievements: achievements,
        now: () => now,
      ),
    ),
  ];
}

UserModel _user(DateTime now) {
  return UserModel(
    id: 'user',
    name: 'Tester',
    level: 6,
    currentXp: 642,
    totalXp: 3120,
    stats: const {
      0: 16.99,
      1: 16.99,
      2: 16.99,
      3: 16.99,
      4: 16.99,
    },
    currentHp: 250,
    maxHp: 250,
    streak: 12,
    longestStreak: 12,
    streakShields: 1,
    title: 'Awakened',
    unlockedTitles: const ['Awakened'],
    bossBattlesWon: 2,
    totalWorkoutsCompleted: 130,
    age: 29,
    height: 181,
    weight: 78,
    fitnessLevel: 'Intermediate',
    processedEventXp: const {'boss:boss': 25},
    createdAt: now.subtract(const Duration(days: 168)),
    updatedAt: now,
  );
}

WorkoutModel _workout(DateTime now) {
  return WorkoutModel(
    id: 'workout',
    date: now,
    createdAt: now,
    completed: true,
    totalXpEarned: 23,
    durationSeconds: 1800,
    processingStateIndex: WorkoutProcessingState.committed.index,
    completionRate: 1,
    masteryPoints: const {'push_up': 24},
    exercises: [
      ExerciseRecord(
        id: 'exercise',
        exerciseTypeIndex: ExerciseType.pushUp.index,
        movementId: 'push_up',
        displayName: 'Push Up',
        variations: [
          VariationRecord(
            id: 'standard',
            name: 'Standard',
            sets: [
              WorkoutSetRecord(
                id: 'set',
                reps: 10,
                completed: true,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

class _FixedUserNotifier extends UserNotifier {
  final UserModel user;

  _FixedUserNotifier(this.user);

  @override
  Future<UserModel?> build() async => user;
}

class _FixedPlanNotifier extends WeeklyPlanNotifier {
  final WorkoutPlanModel plan;

  _FixedPlanNotifier(this.plan);

  @override
  Future<WorkoutPlanModel> build() async => plan;
}

class _FakeWorkoutRepository extends WorkoutRepositoryImpl {
  final List<WorkoutModel> workouts;

  _FakeWorkoutRepository(this.workouts) : super(HiveDatasource());

  @override
  Future<List<WorkoutModel>> getWorkouts({
    DateTime? beforeDate,
    String? beforeId,
    int limit = 20,
    bool committedOnly = true,
  }) async =>
      workouts.take(limit).toList();

  @override
  Future<List<WorkoutModel>> getAllWorkouts({
    bool committedOnly = true,
  }) async =>
      workouts;

  @override
  Future<WorkoutModel?> getWorkout(String id) async {
    return workouts.where((workout) => workout.id == id).firstOrNull;
  }
}

class _FakeBossRepository extends BossRepositoryImpl {
  final List<BossBattleModel> bosses;

  _FakeBossRepository(this.bosses) : super(HiveDatasource());

  @override
  Future<List<BossBattleModel>> getAllBosses() async => bosses;

  @override
  Future<BossBattleModel?> getBoss(String id) async {
    return bosses.where((boss) => boss.id == id).firstOrNull;
  }

  @override
  Future<void> seedDefaultBosses() async {}
}
