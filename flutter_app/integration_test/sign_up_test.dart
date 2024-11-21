import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'random_num_helper.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Sign Up Flow Test', () {
    testWidgets('Sign up and navigate to home screen', (tester) async {
      // Initialize with an empty token to trigger the WelcomeScreen
      await tester.pumpWidget(
        ChangeNotifierProvider<UserState>(
          create: (context) => UserState(),
          child: const MyApp(),
        ),
      );

      // Wait for the widget to load
      await tester.pumpAndSettle();

      // Check for the Welcome screen
      expect(find.text('Prompt-Share Pro'), findsOneWidget);

      final signupButton = find.byKey(const Key('signupButton'));
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).first;
      final usernameField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);
      final uscIdField = find.byType(TextField).at(3);

      // Generate random email and username using the RandomHelper
      final randomNum = RandomHelper.generateRandomEmailAndUsername();

      // Enter text into the form fields with the random email and username
      await tester.enterText(emailField, 'Integrationtest_${randomNum}@usc.edu');
      await tester.enterText(usernameField, 'Integrationtest_${randomNum}');
      await tester.enterText(passwordField, 'integrationtest');
      await tester.enterText(uscIdField, '1234567890');

      final submitSignupButton = find.byKey(const Key('submitSignupButton'));
      await tester.tap(submitSignupButton);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(Duration(seconds: 7));

      // Bottom navigation bar should be visible once logged in
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });
}
