import 'package:flutter_test/flutter_test.dart';
import 'package:ndichow/main.dart';

void main() {
  testWidgets('renders the main food discovery shell', (tester) async {
    await tester.pumpWidget(const NdiChowApp());
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('What are you\nchowing today?'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}
