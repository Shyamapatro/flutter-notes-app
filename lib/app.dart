import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'features/notes/presentation/screens/note_list_screen.dart';
import 'features/notes/presentation/screens/note_editor_screen.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/onboarding/screens/splash_screen.dart';

class LuminaApp extends ConsumerWidget {
  const LuminaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final router = GoRouter(
      initialLocation: '/splash', // Start with Splash
      // refreshListenable: ... Removed Auth Listener
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) => const NoteListScreen(),
        ),
        GoRoute(
          path: '/editor/:noteId',
          builder: (context, state) {
            final noteId = state.pathParameters['noteId']!;
            return NoteEditorScreen(noteId: noteId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Lumina Notes',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark, 
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
