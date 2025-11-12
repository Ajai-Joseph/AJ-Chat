import 'package:aj_chat/home.dart';
import 'package:aj_chat/login.dart';
import 'package:aj_chat/main.dart';
import 'package:aj_chat/theme/app_colors.dart';
import 'package:aj_chat/theme/app_text_styles.dart';
import 'package:aj_chat/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/splash.png',
                width: AppDimensions.splashLogoSize,
                height: AppDimensions.splashLogoSize,
              ),
              const SizedBox(height: AppDimensions.spacingL),
              Text(
                "AJ Chat",
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.onPrimary,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: AppDimensions.spacingXxl),
              const SizedBox(
                width: AppDimensions.splashLoadingIndicatorSize,
                height: AppDimensions.splashLoadingIndicatorSize,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.onPrimary,
                  ),
                  strokeWidth: 3.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> gotoLogin() async {
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  Future<void> checkUserLoggedIn() async {
    final sharedPreference = await SharedPreferences.getInstance();
    final userLoggedIn = sharedPreference.get(saveKey);
    if (userLoggedIn == null || userLoggedIn == false) {
      gotoLogin();
    } else {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }
}
