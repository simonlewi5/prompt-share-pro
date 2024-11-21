import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'random_num_helper.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Test', () {
    testWidgets('Login and navigate to home screen', (tester) async {
      // initialize with an empty token to trigger the WelcomeScreen
      await tester.pumpWidget(
        ChangeNotifierProvider<UserState>(
          create: (context) => UserState(),
          child: const MyApp(),
        ),
      );

      // wait for the widget to load
      await tester.pumpAndSettle();

      // check for welcome screen
      expect(find.text('Prompt-Share Pro'), findsOneWidget);

      final loginButton = find.byKey(const Key('loginButton'));
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      // mock authentication
      await tester.enterText(emailField, 'tester@usc.edu');
      await tester.enterText(passwordField, 'tester');

      final submitLoginButton = find.byKey(const Key('submitLoginButton'));
      await tester.tap(submitLoginButton);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(Duration(seconds: 5));

      // bottom navigation bar should be visible once logged in
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });
  });


  // group('Sign Up Flow Test', () {
  //   testWidgets('Login and navigate to home screen', (tester) async {
  //     // Initialize with an empty token to trigger the WelcomeScreen
  //     await tester.pumpWidget(
  //       ChangeNotifierProvider<UserState>(
  //         create: (context) => UserState(),
  //         child: const MyApp(),
  //       ),
  //     );
  //
  //     // Wait for the widget to load
  //     await tester.pumpAndSettle();
  //
  //     // Check for the Welcome screen
  //     expect(find.text('Prompt-Share Pro'), findsOneWidget);
  //
  //     final signupButton = find.byKey(const Key('signupButton'));
  //     await tester.tap(signupButton);
  //     await tester.pumpAndSettle();
  //
  //     final emailField = find.byType(TextField).first;
  //     final usernameField = find.byType(TextField).at(1);
  //     final passwordField = find.byType(TextField).at(2);
  //     final uscIdField = find.byType(TextField).at(3);
  //
  //     // we need unique email for successful sign up
  //     final randomNum = RandomHelper.generateRandomEmailAndUsername();
  //
  //     await tester.enterText(emailField, 'Integrationtest_${randomNum}@usc.edu');
  //     await tester.enterText(usernameField, 'Integrationtest_${randomNum}');
  //     await tester.enterText(passwordField, 'integrationtest');
  //     await tester.enterText(uscIdField, '1234567890');
  //
  //     final submitSignupButton = find.byKey(const Key('submitSignupButton'));
  //     await tester.tap(submitSignupButton);
  //     await tester.pumpAndSettle();
  //     await tester.pumpAndSettle(Duration(seconds: 5));
  //
  //     expect(find.byType(BottomNavigationBar), findsOneWidget);
  //   });
  // });
}
