import 'package:flutter_test/flutter_test.dart';
import 'package:cryptolicious/main.dart'; // Pastikan ini mengimpor aplikasi Anda yang sebenarnya

void main() {
  testWidgets('Cryptolicious title is displayed', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    // Verify that the title 'Cryptolicious' is displayed on the home screen.
    expect(find.text('Cryptolicious'), findsOneWidget);
  });
}
