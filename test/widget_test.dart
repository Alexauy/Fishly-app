import 'package:fishly_flutter/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Fishly renders startup loading state', (tester) async {
    await tester.pumpWidget(
      FishlyApp(
        firebaseInitialization: Future<void>.delayed(const Duration(days: 1)),
      ),
    );

    expect(find.text('Loading Fishly...'), findsOneWidget);
  });
}
