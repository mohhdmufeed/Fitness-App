import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_fusion/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KineticFusionApp());
    expect(find.byType(KineticFusionApp), findsOneWidget);
  });
}

