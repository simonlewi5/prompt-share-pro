import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';
import 'random_num_helper.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Delete Post Test', () {
    testWidgets('go into profile and delete a post', (tester) async {
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

      // trigger delete on slidable
      final deleteButton = find.byIcon(Icons.delete).first;
      await tester.tap(deleteButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // confirm delete in the dialog
      final confirmDeleteButton = find.text('Delete').first;
      await tester.tap(confirmDeleteButton);
      await tester.pumpAndSettle();

      // wait for ui updates
      await Future.delayed(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // expect to not find the title of the post once the post screen loads again
      expect(find.text(postTitle.data!), findsNothing);
    });
  });
}
