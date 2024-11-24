import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'random_num_helper.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Invalid Sign Up Authentication Test', () {
    testWidgets('Invalid sign-up does not navigate to the HomeScreen', (tester) async {
      // Initialize the app with UserState
      await tester.pumpWidget(
        ChangeNotifierProvider<UserState>(
          create: (context) => UserState(),
          child: const MyApp(),
        ),
      );

      // Wait for the welcome screen to load
      await tester.pumpAndSettle();

      // Navigate to Signup Screen
      final signupButton = find.byKey(const Key('signupButton'));
      await tester.tap(signupButton);
      await tester.pumpAndSettle();

      // Locate form fields
      final emailField = find.byType(TextField).first;
      final usernameField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);
      final uscIdField = find.byType(TextField).at(3);

      // Enter invalid email and submit
      await tester.enterText(emailField, 'bruin@ucla.edu');
      await tester.enterText(usernameField, 'bruin');
      await tester.enterText(passwordField, 'password');
      await tester.enterText(uscIdField, '123');
      final submitSignupButton = find.byKey(const Key('submitSignupButton'));
      await tester.tap(submitSignupButton);

      // Allow time for the screen to settle
      await tester.pumpAndSettle();

      // Assert that we did NOT navigate to HomeScreen (e.g., by checking the absence of the navigation bar)
      expect(find.byType(BottomNavigationBar), findsNothing,
          reason: "Navigation bar should not be visible after an invalid sign-up.");

      // Correct the email and try again
      await tester.enterText(emailField, 'bruin@usc.edu');
      await tester.tap(submitSignupButton);

      // Allow time for the screen to settle
      await tester.pumpAndSettle();

      // Assert again that we did NOT navigate to HomeScreen due to invalid USC ID
      expect(find.byType(BottomNavigationBar), findsNothing,
          reason: "Navigation bar should still not be visible with an invalid USC ID.");
    });
  });
}
