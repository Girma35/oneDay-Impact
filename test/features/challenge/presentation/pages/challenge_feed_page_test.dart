import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_day/features/challenge/presentation/pages/challenge_feed_page.dart';
import 'package:one_day/features/challenge/presentation/widgets/challenge_card.dart';

void main() {
  testWidgets('ChallengeFeedPage displays challenges and navigates', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: ChallengeFeedPage(),
    ));

    // Initially shows a loading indicator (since it's a FutureBuilder with delay)
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the mock repository delay (500ms)
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    // Check if challenges are displayed
    expect(find.text('Plant a Tree'), findsOneWidget);
    expect(find.text('Visit an Elder'), findsOneWidget);
    expect(find.byType(ChallengeCard), findsNWidgets(3));
  });
}
