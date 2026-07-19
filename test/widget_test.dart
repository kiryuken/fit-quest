import 'package:fitquest_rpg/app.dart';
import 'package:fitquest_rpg/data/models/user_model.dart';
import 'package:fitquest_rpg/providers/initialization_provider.dart';
import 'package:fitquest_rpg/providers/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders smoke test', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initializationProvider.overrideWith((ref) => AppInitState.ready),
          userProvider.overrideWith(_NoUserNotifier.new),
        ],
        child: const FitQuestApp(),
      ),
    );

    expect(find.byType(FitQuestApp), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}

class _NoUserNotifier extends UserNotifier {
  @override
  Future<UserModel?> build() async => null;
}
