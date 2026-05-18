import 'package:flutter_test/flutter_test.dart';
import 'package:medicall/main.dart';

void main() {
  testWidgets('MediCall app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MediCallApp());
    expect(find.text('MédiCall'), findsWidgets);
  });
}
