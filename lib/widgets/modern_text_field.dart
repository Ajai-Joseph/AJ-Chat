import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// Modern text field component with outlined style and floating labels
/// Supports prefix icons, suffix icons, and password visibility toggle
class ModernTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool isPassword;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const ModernTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.isPassword = false,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  State<ModernTextField> createState() => _ModernTextFieldState();
}

class _ModernTextFieldState extends State<ModernTextField> {
  bool _obscureText = true;
  bool _isFocused = false;
  late FocusNode _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _internalFocusNode = widget.focusNode ?? FocusNode();
    _internalFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _internalFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _internalFocusNode.hasFocus;
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
            boxShadow: _isFocused && !hasError
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _internalFocusNode,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            maxLines: widget.isPassword ? 1 : widget.maxLines,
            minLines: widget.minLines,
            enabled: widget.enabled,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            textInputAction: widget.textInputAction,
            autofocus: widget.autofocus,
            style: AppTextStyles.inputText,
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              errorText: null, // We'll show error below
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppColors.primary
                          : hasError
                              ? AppColors.error
                              : AppColors.textSecondary,
                      size: AppDimensions.iconSizeMedium,
                    )
                  : null,
              suffixIcon: _buildSuffixIcon(hasError),
              filled: true,
              fillColor: widget.enabled ? AppColors.surface : AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.inputPaddingHorizontal,
                vertical: AppDimensions.inputPaddingVertical,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                borderSide: BorderSide(
                  color: hasError ? AppColors.borderError : AppColors.border,
                  width: AppDimensions.inputBorderWidth,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                borderSide: BorderSide(
                  color: hasError ? AppColors.borderError : AppColors.border,
                  width: AppDimensions.inputBorderWidth,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                borderSide: BorderSide(
                  color: hasError ? AppColors.borderError : AppColors.borderFocused,
                  width: AppDimensions.inputBorderWidth,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                borderSide: const BorderSide(
                  color: AppColors.borderError,
                  width: AppDimensions.inputBorderWidth,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.inputBorderRadius),
                borderSide: const BorderSide(
                  color: AppColors.borderError,
                  width: AppDimensions.inputBorderWidth,
                ),
              ),
              labelStyle: AppTextStyles.inputLabel.copyWith(
                color: _isFocused
                    ? AppColors.primary
                    : hasError
                        ? AppColors.error
                        : AppColors.textSecondary,
              ),
              hintStyle: AppTextStyles.inputLabel.copyWith(
                color: AppColors.textTertiary,
              ),
              floatingLabelStyle: AppTextStyles.inputLabel.copyWith(
                color: _isFocused
                    ? AppColors.primary
                    : hasError
                        ? AppColors.error
                        : AppColors.textSecondary,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: AppDimensions.spacingXs),
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: AppDimensions.spacingXs),
              Expanded(
                child: Text(
                  widget.errorText!,
                  style: AppTextStyles.inputError,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget? _buildSuffixIcon(bool hasError) {
    if (widget.isPassword) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: _isFocused
              ? AppColors.primary
              : hasError
                  ? AppColors.error
                  : AppColors.textSecondary,
          size: AppDimensions.iconSizeMedium,
        ),
        onPressed: _togglePasswordVisibility,
      );
    }

    if (widget.suffixIcon != null) {
      return IconButton(
        icon: Icon(
          widget.suffixIcon,
          color: _isFocused
              ? AppColors.primary
              : hasError
                  ? AppColors.error
                  : AppColors.textSecondary,
          size: AppDimensions.iconSizeMedium,
        ),
        onPressed: widget.onSuffixIconTap,
      );
    }

    return null;
  }
}
