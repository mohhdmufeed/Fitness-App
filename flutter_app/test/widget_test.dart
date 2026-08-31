import 'package:flutter_test/flutter_test.dart';
import 'package:kinetic_fusion/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const KineticFusionApp());
    expect(find.byType(KineticFusionApp), findsOneWidget);
  });
}

