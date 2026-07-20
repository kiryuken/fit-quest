import 'package:fitquest_rpg/app.dart';
import 'package:fitquest_rpg/core/routing/app_router.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/features/onboarding/presentation/screens/character_creation_screen.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('cold start reaches onboarding for a new local user',
      (tester) async {
    appRouter.go('/splash');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initializationProvider.overrideWith((ref) => AppInitState.ready),
          userProvider.overrideWith(_NoUserNotifier.new),
        ],
        child: const FitQuestApp(),
      ),
    );

    expect(find.text('FITQUEST'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(CharacterCreationScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _NoUserNotifier extends UserNotifier {
  @override
  Future<UserModel?> build() async => null;
}
