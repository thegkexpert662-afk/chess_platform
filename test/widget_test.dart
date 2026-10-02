import 'package:flutter_test/flutter_test.dart';
import 'package:chess_platform/app/app.dart';

void main() {
  testWidgets('login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ChessPlatformApp());
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
