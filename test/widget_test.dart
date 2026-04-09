import 'package:flutter_test/flutter_test.dart';
import 'package:smart_campus_ai_platform/main.dart';

void main() {
  testWidgets('Smart Campus App loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartCampusApp());

    expect(find.text("Smart Campus Login"), findsOneWidget);
    expect(find.text("Student"), findsWidgets);
  });
}
