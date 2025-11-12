import 'package:aj_chat/theme/app_colors.dart';
import 'package:aj_chat/theme/app_dimensions.dart';
import 'package:aj_chat/theme/app_text_styles.dart';
import 'package:aj_chat/utils/toast_helper.dart';
import 'package:aj_chat/widgets/modern_button.dart';
import 'package:aj_chat/widgets/modern_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _emailError = _emailController.text.isEmpty ? "Enter Email" : null;
    });
    return _emailError == null;
  }

  Future<void> _sendResetEmail() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text);

      if (!mounted) return;

      ToastHelper.showSuccess("Password reset email sent successfully");
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Failed to send reset email";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found with this email";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
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
                  child: Stack(
                    children: [
                      // Back Button
                      Positioned(
                        left: AppDimensions.paddingM,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.onPrimary,
                              size: AppDimensions.iconSizeLarge,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      // Title
                      Center(
                        child: Text(
                          "Reset Password",
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ],
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Icon
                              Container(
                                padding: const EdgeInsets.all(AppDimensions.paddingL),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_reset,
                                  size: 48,
                                  color: AppColors.onPrimary,
                                ),
                              ),
                              const SizedBox(height: AppDimensions.spacingL),
                              
                              Text(
                                "Forgot Password?",
                                style: AppTextStyles.h2,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppDimensions.spacingM),
                              
                              Text(
                                "Enter your email address and we'll send you a link to reset your password.",
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
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
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _sendResetEmail(),
                                onChanged: (_) {
                                  if (_emailError != null) {
                                    setState(() {
                                      _emailError = null;
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: AppDimensions.spacingXl),

                              // Send Request Button
                              ModernButton(
                                text: "Send Reset Link",
                                onPressed: _isLoading ? null : _sendResetEmail,
                                isLoading: _isLoading,
                                variant: ModernButtonVariant.primary,
                              ),
                              const SizedBox(height: AppDimensions.spacingM),

                              // Back to Login Button
                              ModernButton(
                                text: "Back to Login",
                                onPressed: _isLoading
                                    ? null
                                    : () => Navigator.of(context).pop(),
                                variant: ModernButtonVariant.outlined,
                              ),
                            ],
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
