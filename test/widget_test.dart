import 'package:flutter_test/flutter_test.dart';
import 'package:c_qube/main.dart';

void main() {
  testWidgets('C-QUBE loads welcome role selection screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CQubeApp());
    await tester.pumpAndSettle();

    // Verify title and role choices exist
    expect(find.text('C-QUBE'), findsOneWidget);
    expect(find.text('Campus × Club × Connect'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Club / Coordinator'), findsOneWidget);
  });
}
