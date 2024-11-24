import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Rate Post Test', () {
    testWidgets('Login and navigate to home screen and then click on a post then rate it', (tester) async {
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

      // Navigate to the first post by searching for post title "RATE POST TEST"
      final searchBar = find.byKey(const Key('searchBar'));
      await tester.tap(searchBar);
      await tester.enterText(searchBar, 'RATE POST TEST');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // click on the post
      final post = find.byKey(const Key('RATE POST TEST'));
      await tester.tap(post);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // click on the rate button
      final rateButton = find.byKey(const Key('rateButton'));
      await tester.tap(rateButton);
      await tester.pumpAndSettle();

      // select a rating
      final rateOption = find.text('5');
      await tester.tap(rateOption);
      await tester.pumpAndSettle();
    });
  });
}