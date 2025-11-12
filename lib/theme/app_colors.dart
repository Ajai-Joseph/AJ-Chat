import 'package:flutter/material.dart';

/// Centralized color palette for the AJ Chat application
/// Following Material Design 3 principles
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF8B5CF6);
  static const Color primaryContainer = Color(0xFFEDE9FE);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Primary Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Secondary Colors
  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryContainer = Color(0xFFCCFBF1);
  static const Color onSecondary = Color(0xFF1F2937);

  // Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF3F4F6);
  static const Color background = Color(0xFFF9FAFB);
  static const Color onSurface = Color(0xFF111827);
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // Message Colors
  static const Color sentMessageBackground = primary;
  static const Color receivedMessageBackground = Color(0xFFE5E7EB);
  static const Color sentMessageText = Color(0xFFFFFFFF);
  static const Color receivedMessageText = Color(0xFF111827);

  // Message Gradient (for sent messages)
  static const LinearGradient messageGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Additional UI Colors
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);

  // Online Status
  static const Color onlineStatus = Color(0xFF10B981);
  static const Color offlineStatus = Color(0xFF9CA3AF);

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Border Colors
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderFocused = primary;
  static const Color borderError = error;
}
