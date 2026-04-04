import 'package:flutter/material.dart';

import 'screens/root_shell.dart';
import 'theme/fishly_theme.dart';

class FishlyApp extends StatelessWidget {
  const FishlyApp({super.key, required this.firebaseInitialization});

  final Future<void> firebaseInitialization;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishly',
      debugShowCheckedModeBanner: false,
      theme: FishlyTheme.themeData,
      home: FutureBuilder<void>(
        future: firebaseInitialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _StartupLoadingScreen();
          }
          if (snapshot.hasError) {
            return _StartupErrorScreen(error: snapshot.error.toString());
          }
          return const RootShell();
        },
      ),
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAFF),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEAFBFF),
                    Color(0xFFBFE8FF),
                    Color(0xFF74C7F4),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5E9FC0).withValues(alpha: 0.24),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFF2478A6),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Loading Fishly...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF1C5373),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StartupErrorScreen extends StatelessWidget {
  const _StartupErrorScreen({required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FAFF),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Fishly had trouble starting',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF1C5373),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                error,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF43657A),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
