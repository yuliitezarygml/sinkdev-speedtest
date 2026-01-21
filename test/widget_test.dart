import 'package:flutter_test/flutter_test.dart';
import 'package:speedtest/main.dart';

void main() {
  testWidgets('Speed test UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SpeedTestApp());

    // Verify that the title and start button are present.
    expect(find.text('SPEED TEST'), findsOneWidget);
    expect(find.text('START TEST'), findsOneWidget);
  });
}
