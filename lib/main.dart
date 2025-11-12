import 'package:aj_chat/splash_screen.dart';
import 'package:aj_chat/theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const saveKey = "isLoggedIn";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AJ Chat',
      // Use centralized theme configuration with Material Design 3
      theme: AppTheme.lightTheme,
      // Dark theme support (currently returns light theme)
      darkTheme: AppTheme.darkTheme,
      // Use system theme mode (can be changed to ThemeMode.light or ThemeMode.dark)
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
