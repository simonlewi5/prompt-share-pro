import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'random_num_helper.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Update Post Test', () {
    testWidgets('go into profile and update a post', (tester) async {
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

      // navigate to the profile page
      final profileScreenButton = find.byIcon(Icons.person);
      await tester.tap(profileScreenButton);
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsAny);

      // go to screen with user posts
      final viewUserPostsButton = find.byKey(const Key('viewPostsButton'));
      await tester.tap(viewUserPostsButton);
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // select any post - let's just do the first post
      final firstPost = find.byType(ListTile).first;
      final postTitle = (firstPost.evaluate().single.widget as ListTile).title as Text;
      await tester.pumpAndSettle();
      await tester.drag(firstPost, const Offset(-500.0, 0.0));
      await tester.pumpAndSettle();

      // trigger edit on slidable
      final editButton = find.byIcon(Icons.edit).first;
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // get fields
      final title = find.byType(TextField).first;
      final content = find.byType(TextField).at(1);
      final authorNotes = find.byType(TextField).at(2);
      final llmKind = find.byType(ElevatedButton).first;

      final randomNum = RandomHelper.generateRandomEmailAndUsername();

      // Enter text into the form fields with the random email and username
      await tester.enterText(title, 'changeTitle_${randomNum}');
      await tester.enterText(content, 'changeContent_${randomNum}');
      await tester.enterText(authorNotes, 'changedaAuthorNotes_${randomNum}');

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

      // confirm changes
      final confirmChangesButton = find.byKey(const Key('EditPostSubmitButton'));
      await tester.tap(confirmChangesButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // expect to not find the title of the post once the post screen loads again
      expect(find.text(postTitle.data!), findsNothing);
    });
  });
}
