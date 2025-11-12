import 'dart:io';
import 'package:aj_chat/theme/app_colors.dart';
import 'package:aj_chat/theme/app_dimensions.dart';
import 'package:aj_chat/theme/app_text_styles.dart';
import 'package:aj_chat/utils/toast_helper.dart';
import 'package:aj_chat/widgets/modern_button.dart';
import 'package:aj_chat/widgets/modern_text_field.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  XFile? _image;
  String? _imgUrl;
  bool _isLoading = false;
  String? _nameError;
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _validateForm() {
    setState(() {
      _nameError = _nameController.text.isEmpty ? "Enter Name" : null;
      _emailError = _emailController.text.isEmpty ? "Enter Email" : null;
      _passwordError = _passwordController.text.isEmpty ? "Enter Password" : null;
    });
    return _nameError == null && _emailError == null && _passwordError == null;
  }

  Future<void> _registerUser() async {
    if (!_validateForm()) return;

    if (_image == null) {
      ToastHelper.showWarning("Please upload your photo");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Reference firebaseStorage = FirebaseStorage.instance
          .ref()
          .child("Profile Photos")
          .child(_auth.currentUser!.uid);
      UploadTask uploadTask = firebaseStorage.putFile(File(_image!.path));
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => {});
      await taskSnapshot.ref.getDownloadURL().then((url) => {_imgUrl = url});

      await _firestore.collection("Users").doc(_auth.currentUser!.uid).set({
        'Name': _nameController.text,
        'Email': _emailController.text,
        'Image': _imgUrl,
        'Password': _passwordController.text,
        'Id': _auth.currentUser!.uid,
      });

      if (!mounted) return;

      ToastHelper.showSuccess("Registration Successful");
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = "Password is too weak";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Email is already registered";
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

  Future<void> _takePhoto(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source);
    setState(() {
      _image = img;
    });
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(AppDimensions.paddingM),
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.bottomSheetRadius),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 16,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: AppDimensions.bottomSheetHandleWidth,
              height: AppDimensions.bottomSheetHandleHeight,
              margin: const EdgeInsets.only(bottom: AppDimensions.spacingL),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
            ),
            Text(
              "Choose profile photo",
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ModernButton(
                    text: "Camera",
                    icon: Icons.camera_alt_outlined,
                    onPressed: () {
                      _takePhoto(ImageSource.camera);
                      Navigator.of(context).pop();
                    },
                    variant: ModernButtonVariant.outlined,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingM),
                Expanded(
                  child: ModernButton(
                    text: "Gallery",
                    icon: Icons.image_outlined,
                    onPressed: () {
                      _takePhoto(ImageSource.gallery);
                      Navigator.of(context).pop();
                    },
                    variant: ModernButtonVariant.outlined,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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
                      "Sign Up",
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
                      vertical: AppDimensions.paddingL,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          // Profile Photo Picker with Modern Card Design
                          InkWell(
                            onTap: _showImagePickerBottomSheet,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 3,
                                  strokeAlign: BorderSide.strokeAlignOutside,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: AppColors.shadow,
                                    blurRadius: 12,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Stack(
                                children: [
                                  // Avatar Image
                                  ClipOval(
                                    child: _image == null
                                        ? Container(
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceVariant,
                                              border: Border.all(
                                                color: AppColors.primary,
                                                width: 2,
                                                strokeAlign: BorderSide.strokeAlignInside,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.person_outline,
                                                size: 60,
                                                color: AppColors.textSecondary,
                                              ),
                                            ),
                                          )
                                        : Image.file(
                                            File(_image!.path),
                                            width: 140,
                                            height: 140,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                  // Camera Icon Overlay
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surface,
                                          width: 3,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: AppColors.onPrimary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXl),

                          // Form Fields Card
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
                                    "Create Account",
                                    style: AppTextStyles.h2,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppDimensions.spacingXl),

                                  // Name Field
                                  ModernTextField(
                                    controller: _nameController,
                                    labelText: "Name",
                                    hintText: "Enter your name",
                                    prefixIcon: Icons.person_outlined,
                                    errorText: _nameError,
                                    textInputAction: TextInputAction.next,
                                    onChanged: (_) {
                                      if (_nameError != null) {
                                        setState(() {
                                          _nameError = null;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: AppDimensions.spacingL),

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
                                    onSubmitted: (_) => _registerUser(),
                                    onChanged: (_) {
                                      if (_passwordError != null) {
                                        setState(() {
                                          _passwordError = null;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(height: AppDimensions.spacingXl),

                                  // Sign Up Button
                                  ModernButton(
                                    text: "Sign Up",
                                    onPressed: _isLoading ? null : _registerUser,
                                    isLoading: _isLoading,
                                    variant: ModernButtonVariant.primary,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
