import 'package:aj_chat/home.dart';
import 'package:aj_chat/main.dart';
import 'package:aj_chat/reset_password_screen.dart';
import 'package:aj_chat/sign_up_screen.dart';
import 'package:aj_chat/theme/app_colors.dart';
import 'package:aj_chat/theme/app_dimensions.dart';
import 'package:aj_chat/theme/app_text_styles.dart';
import 'package:aj_chat/utils/toast_helper.dart';
import 'package:aj_chat/widgets/modern_button.dart';
import 'package:aj_chat/widgets/modern_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _emailError = _emailController.text.isEmpty ? "Enter Email" : null;
      _passwordError = _passwordController.text.isEmpty ? "Enter Password" : null;
    });
    return _emailError == null && _passwordError == null;
  }

  Future<void> _signIn() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final sharedPreference = await SharedPreferences.getInstance();
      await sharedPreference.setBool(saveKey, true);

      if (!mounted) return;

      ToastHelper.showSuccess("Login Successful");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login Failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Incorrect password";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (e.code == 'user-disabled') {
        errorMessage = "This account has been disabled";
      }
      ToastHelper.showError(errorMessage);
    } catch (e) {
      ToastHelper.showError("An unexpected error occurred");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * 0.2;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight - MediaQuery.of(context).padding.top,
            child: Column(
              children: [
                // Gradient Header Section (20% of screen height)
                Container(
                  height: headerHeight,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  child: Center(
                    child: Text(
                      "AJ Chat",
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.onPrimary,
                      ),
                    ),
                  ),
                ),
                
                // Form Section
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingL,
                      vertical: AppDimensions.paddingXl,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Elevated White Card Container
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.paddingL),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 16,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  "Welcome Back",
                                  style: AppTextStyles.h2,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppDimensions.spacingXl),
                                
                                // Email Field
                                ModernTextField(
                                  controller: _emailController,
                                  labelText: "Email",
                                  hintText: "Enter your email",
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  errorText: _emailError,
                                  textInputAction: TextInputAction.next,
                                  onChanged: (_) {
                                    if (_emailError != null) {
                                      setState(() {
                                        _emailError = null;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: AppDimensions.spacingL),
                                
                                // Password Field
                                ModernTextField(
                                  controller: _passwordController,
                                  labelText: "Password",
                                  hintText: "Enter your password",
                                  prefixIcon: Icons.lock_outlined,
                                  isPassword: true,
                                  errorText: _passwordError,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: (_) => _signIn(),
                                  onChanged: (_) {
                                    if (_passwordError != null) {
                                      setState(() {
                                        _passwordError = null;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: AppDimensions.spacingM),
                                
                                // Forgot Password Button
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => const ResetPasswordScreen(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      "Forgot Password?",
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingL),
                                
                                // Sign In Button
                                ModernButton(
                                  text: "Sign In",
                                  onPressed: _isLoading ? null : _signIn,
                                  isLoading: _isLoading,
                                  variant: ModernButtonVariant.primary,
                                ),
                                const SizedBox(height: AppDimensions.spacingM),
                                
                                // Sign Up Button
                                ModernButton(
                                  text: "Sign Up",
                                  onPressed: _isLoading
                                      ? null
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => const SignUpScreen(),
                                            ),
                                          );
                                        },
                                  variant: ModernButtonVariant.outlined,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
