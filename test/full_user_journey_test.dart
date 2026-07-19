import 'package:fitquest_rpg/app.dart';
import 'package:fitquest_rpg/core/routing/app_router.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/features/onboarding/presentation/screens/character_creation_screen.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FitQuest app shell', () {
    setUp(() => appRouter.go('/splash'));

    testWidgets('renders the splash screen without crashing', (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('FITQUEST'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await _finishSplash(tester);
    });

    testWidgets('loads the configured dark Material theme', (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pump();

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.theme?.brightness, Brightness.dark);
      expect(tester.takeException(), isNull);

      await _finishSplash(tester);
    });

    testWidgets('is mounted inside a ProviderScope', (tester) async {
      await tester.pumpWidget(_testApp());
      await tester.pump();

      final context = tester.element(find.byType(FitQuestApp));
      expect(
        () => ProviderScope.containerOf(context, listen: false),
        returnsNormally,
      );

      await _finishSplash(tester);
    });

    testWidgets('navigates a new user from splash to onboarding',
        (tester) async {
      await tester.pumpWidget(_testApp());

      await _finishSplash(tester);

      expect(find.byType(CharacterCreationScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _testApp() {
  return ProviderScope(
    overrides: [
      initializationProvider.overrideWith((ref) => AppInitState.ready),
      userProvider.overrideWith(_NoUserNotifier.new),
    ],
    child: const FitQuestApp(),
  );
}

Future<void> _finishSplash(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

class _NoUserNotifier extends UserNotifier {
  @override
  Future<UserModel?> build() async => null;
}
