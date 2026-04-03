import 'package:flutter/material.dart';

import 'screens/root_shell.dart';
import 'theme/fishly_theme.dart';

class FishlyApp extends StatelessWidget {
  const FishlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishly',
      debugShowCheckedModeBanner: false,
      theme: FishlyTheme.themeData,
      home: const RootShell(),
    );
  }
}
