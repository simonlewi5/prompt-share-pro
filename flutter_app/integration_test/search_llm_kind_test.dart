import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_app/main.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/core/services/user_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Search by LLM Kind Flow Test', () {
    testWidgets('Change the search type to LLM kind', (tester) async {
      // Initialize the app with a mock user state
      await tester.pumpWidget(
        ChangeNotifierProvider<UserState>(
          create: (context) => UserState(),
          child: const MyApp(),
        ),
      );

      // Wait for the initial build
      await tester.pumpAndSettle();

      // Check for the welcome screen
      expect(find.text('Prompt-Share Pro'), findsOneWidget);

      // Navigate through the login process
      final loginButton = find.byKey(const Key('loginButton'));
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      final emailField = find.byType(TextField).first;
      final passwordField = find.byType(TextField).at(1);

      // Enter login credentials
      await tester.enterText(emailField, 'tester@usc.edu');
      await tester.enterText(passwordField, 'tester');

      // Submit login
      final submitLoginButton = find.byKey(const Key('submitLoginButton'));
      await tester.tap(submitLoginButton);
      await tester.pumpAndSettle(Duration(seconds: 5));

      // Ensure the bottom navigation bar is visible
      expect(find.byType(BottomNavigationBar), findsOneWidget);

      // Open the filter menu and select "LLM"
      final filterMenu = find.byKey(const Key('popupMenuButton'));
      await tester.tap(filterMenu);
      await tester.pumpAndSettle();

      final llmFilterOption = find.text('LLM');
      await tester.tap(llmFilterOption);
      await tester.pumpAndSettle();

      // Verify that the filter has been set to "LLM"
      expect(find.textContaining('Search by LLM'), findsOneWidget);
    });
  });
}