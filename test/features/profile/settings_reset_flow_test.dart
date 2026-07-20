import 'package:fitquest_rpg/app.dart';
import 'package:fitquest_rpg/core/enums/stat_type.dart';
import 'package:fitquest_rpg/core/routing/app_router.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/features/onboarding/presentation/screens/character_creation_screen.dart';
import 'package:fitquest_rpg/providers/game_reset_provider.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/quest_provider.dart';
import 'package:fitquest_rpg/providers/settings_preferences_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _settle(WidgetTester tester, {int cycles = 10}) async {
  for (var i = 0; i < cycles; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

void main() {
  testWidgets(
      'reset from settings navigates to onboarding and allows a new character',
      (tester) async {
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    final now = DateTime(2026, 7, 19);
    final userNotifier = _FlowUserNotifier(
      UserModel(
        id: 'user-1',
        name: 'Veteran',
        lastWorkoutAt: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
    var resetCalls = 0;

    appRouter.go('/splash');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initializationProvider.overrideWith(
            (ref) => AppInitState.ready,
          ),
          settingsPreferencesProvider.overrideWithValue(
            _FakeSettingsPreferences(),
          ),
          questProvider.overrideWith(
            (ref) => QuestNotifier.forTesting(
              initialQuests: const [],
              onExpReward: (_, __) async {},
            ),
          ),
          userProvider.overrideWith(() => userNotifier),
          gameResetServiceProvider.overrideWith(
            (ref) => _FakeGameResetService(
              ref,
              onReset: () {
                resetCalls++;
                userNotifier.reset();
              },
            ),
          ),
        ],
        child: const FitQuestApp(),
      ),
    );

    await tester.pump(const Duration(seconds: 2));
    await _settle(tester, cycles: 3);

    appRouter.go('/profile/settings');
    await _settle(tester, cycles: 3);

    final resetCard = find.text('Reset all data');
    await tester.scrollUntilVisible(
      resetCard,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(resetCard);
    await _settle(tester, cycles: 3);

    await tester.tap(find.text('DELETE EVERYTHING'));
    await _settle(tester);

    expect(find.byType(CharacterCreationScreen), findsOneWidget);
    expect(resetCalls, 1);
    expect(userNotifier.currentUser, isNull);

    final onboardingContext =
        tester.element(find.byType(CharacterCreationScreen));
    ScaffoldMessenger.of(onboardingContext).removeCurrentSnackBar();
    await tester.pump();

    final beginButton = find.text('BEGIN THE ADVENTURE');
    final onboardingScroll = find.descendant(
      of: find.byType(CustomScrollView),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Scrollable && widget.axisDirection == AxisDirection.down,
      ),
    );
    expect(onboardingScroll, findsOneWidget);
    await tester.scrollUntilVisible(
      beginButton,
      400,
      scrollable: onboardingScroll,
    );
    await tester.tap(beginButton);
    await _settle(tester);

    expect(find.byType(CharacterCreationScreen), findsNothing);
    expect(userNotifier.recreatedUser?.name, 'Warrior');
  });
}

class _FakeSettingsPreferences implements SettingsPreferences {
  var _notificationsEnabled = false;

  @override
  bool get notificationsEnabled => _notificationsEnabled;

  @override
  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
  }
}

class _FakeGameResetService extends GameResetService {
  final void Function() onReset;

  _FakeGameResetService(
    super.ref, {
    required this.onReset,
  });

  @override
  Future<void> resetAllData() async => onReset();
}

class _FlowUserNotifier extends UserNotifier {
  final UserModel initialUser;
  UserModel? recreatedUser;

  _FlowUserNotifier(this.initialUser);

  UserModel? get currentUser => state.valueOrNull;

  @override
  Future<UserModel?> build() async => initialUser;

  void reset() {
    state = const AsyncData(null);
  }

  @override
  Future<UserModel> createCharacter({
    required String name,
    int age = 18,
    double height = 170,
    double weight = 70,
    String fitnessLevel = 'Beginner',
    StatType? preferredFocus,
  }) async {
    final now = DateTime(2026, 7, 19);
    final user = UserModel(
      id: 'new-user',
      name: name,
      lastWorkoutAt: now,
      createdAt: now,
      updatedAt: now,
      age: age,
      height: height,
      weight: weight,
      preferredFocusIndex: preferredFocus?.index,
    );
    recreatedUser = user;
    state = AsyncData(user);
    return user;
  }
}
