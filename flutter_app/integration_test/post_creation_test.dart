import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'random_num_helper.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Post Creation Test', () {
    testWidgets('Navigate to Create Post Screen', (tester) async {
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

      // go to post creation screen
      final createPostScreenButton = find.byKey(const Key('createPostScreenButton'));
      await tester.tap(createPostScreenButton);
      await tester.pumpAndSettle();

      // fill in fields
      final titleField = find.byType(TextField).first;
      final contentField = find.byType(TextField).at(1);
      final authorNotesField = find.byType(TextField).at(2);
      final llmKind = find.byType(ElevatedButton).first;

      final randomNum = RandomHelper.generateRandomEmailAndUsername();

      await tester.enterText(titleField, 'Test Post_${randomNum}');
      await tester.enterText(contentField, 'This is a test post');
      await tester.enterText(authorNotesField, 'This is a test post');

      // tapping llm kind will open up an alert dialog box
      await tester.runAsync(() async {
        await tester.tap(llmKind);
      });
      await tester.pumpAndSettle();

      final gpt3Checkbox = find.text('GPT-3');
      final bertCheckbox = find.text('BERT');

      await tester.tap(gpt3Checkbox);
      await tester.pump();
      await tester.tap(bertCheckbox);
      await tester.pump();

      final confirmLLMs = find.widgetWithText(ElevatedButton, 'Confirm');
      await tester.tap(confirmLLMs);
      await tester.pumpAndSettle();

      // submit post
      final submitPostButton = find.byKey(const Key('createPostSubmitButton'));
      await tester.tap(submitPostButton);
      await tester.pumpAndSettle();

      // check if post created successfully
      expect(find.text("Post created successfully"), findsOneWidget);
    });
  });
}
