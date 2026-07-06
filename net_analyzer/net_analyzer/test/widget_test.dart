import 'package:flutter_test/flutter_test.dart';
import 'package:net_analyzer/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const NetAnalyzerApp(initialLocation: '/welcome'),
    );
    expect(find.byType(NetAnalyzerApp), findsOneWidget);
  });
}
