import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Edit Profile Flow Test', () {
    testWidgets('Navigate to profile screen and edit username and picture', (tester) async {
      // Initialize the app with a mock user state
      await tester.pumpWidget(
        ChangeNotifierProvider<UserState>(
          create: (context) => UserState(),
          child: const MyApp(),
        ),
      );

      // Wait for the widget to load
      await tester.pumpAndSettle();

      // Check for the welcome screen
      expect(find.text('Prompt-Share Pro'), findsOneWidget);

      // Tap the login button
      final loginButton = find.byKey(const Key('loginButton'));
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Enter mock authentication details
      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'tester@usc.edu');
      await tester.enterText(passwordField, 'tester');

      // Submit login
      final submitLoginButton = find.byKey(const Key('submitLoginButton'));
      await tester.tap(submitLoginButton);
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Ensure the bottom navigation bar is visible
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Navigate to profile screen
      final profileButton = find.byIcon(Icons.person);
      await tester.tap(profileButton);
      await tester.pumpAndSettle();

      // Check for the profile screen
      expect(find.text('Username'), findsOneWidget);

      // Tap the edit profile button
      final editProfileButton = find.byKey(const Key('popupMenuButton'));
      await tester.tap(editProfileButton);
      await tester.pumpAndSettle();

      // Select the edit profile option
      final editProfileOption = find.text('Edit Profile');
      await tester.tap(editProfileOption);
      await tester.pumpAndSettle();

      // Ensure the edit profile screen is loaded
      expect(find.text('Edit Profile'), findsOneWidget);

      // Clear the previous username
      final usernameField = find.byType(TextField);
      await tester.enterText(usernameField, '');
      await tester.pumpAndSettle();

      // Enter a new username
      await tester.enterText(usernameField, 'new_username');
      await tester.pumpAndSettle();

      // Tap the avatar to open the image selection dialog
      final avatar = find.byType(CircleAvatar);
      await tester.tap(avatar);
      await tester.pumpAndSettle();

      // Check for the image selection dialog
      expect(find.text('Select a Profile Picture'), findsOneWidget);

      // Select an image
      final image = find.byType(GestureDetector).last;
      await tester.tap(image);
      await tester.pumpAndSettle(Duration(seconds: 2));

      // Ensure the avatar is updated
      expect(find.byType(CircleAvatar), findsOneWidget);

      // Save changes
      final saveButton = find.byKey(const Key('saveButton'));
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Confirm the changes
      final confirmButton = find.text('Save');
      await tester.tap(confirmButton);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Check for the updated username on the profile screen
      expect(find.text('new_username'), findsOneWidget);

      // Check for the updated avatar on the profile screen
      expect(find.byType(CircleAvatar), findsOneWidget);

      //revert back to original username and avatar
      await tester.tap(editProfileButton);
      await tester.pumpAndSettle();
      await tester.tap(editProfileOption);
      await tester.pumpAndSettle();
      await tester.enterText(usernameField, '');
      await tester.pumpAndSettle();
      await tester.enterText(usernameField, 'tester');
      await tester.pumpAndSettle();
      await tester.tap(avatar);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle(Duration(seconds: 2));
      await tester.tap(saveButton);
      await tester.pumpAndSettle();
      await tester.tap(confirmButton);
      await tester.pumpAndSettle(Duration(seconds: 3));
    });
  });
}