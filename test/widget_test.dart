import 'package:fishly_flutter/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Fishly renders root shell', (tester) async {
    await tester.pumpWidget(const FishlyApp());
    expect(find.text('Fishly'), findsNothing);
    expect(find.textContaining('underwater adventure'), findsOneWidget);
  });
}
