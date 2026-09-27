import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:travella/main.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  testWidgets('TravellaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TravellaApp());
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TravellaApp), findsOneWidget);
  });
}
