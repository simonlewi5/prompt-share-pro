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
}
