import 'package:aj_chat/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

/// Helper class for showing toast messages with consistent modern styling
class ToastHelper {
  ToastHelper._();

  /// Show a success toast message
  static void showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.success,
      textColor: AppColors.onPrimary,
      fontSize: 14.0,
      timeInSecForIosWeb: 3,
    );
  }

  /// Show an error toast message
  static void showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.error,
      textColor: AppColors.onPrimary,
      fontSize: 14.0,
      timeInSecForIosWeb: 3,
    );
  }

  /// Show an info toast message
  static void showInfo(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.info,
      textColor: AppColors.onPrimary,
      fontSize: 14.0,
      timeInSecForIosWeb: 3,
    );
  }

  /// Show a warning toast message
  static void showWarning(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppColors.warning,
      textColor: AppColors.onPrimary,
      fontSize: 14.0,
      timeInSecForIosWeb: 3,
    );
  }

  /// Show a generic toast message with custom styling
  static void show(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    ToastGravity? gravity,
    Toast? length,
  }) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: length ?? Toast.LENGTH_SHORT,
      gravity: gravity ?? ToastGravity.BOTTOM,
      backgroundColor: backgroundColor ?? AppColors.info,
      textColor: textColor ?? AppColors.onPrimary,
      fontSize: 14.0,
      timeInSecForIosWeb: 3,
    );
  }
}
