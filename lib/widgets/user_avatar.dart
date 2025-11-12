import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';

/// User avatar component with circular shape and network image support
/// Supports online status indicator and gradient border for featured users
enum AvatarSize {
  small,
  medium,
  large,
  extraLarge,
}

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final AvatarSize size;
  final bool showOnlineStatus;
  final bool isOnline;
  final bool hasGradientBorder;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = AvatarSize.medium,
    this.showOnlineStatus = false,
    this.isOnline = false,
    this.hasGradientBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarSize = _getAvatarSize();
    final borderWidth = hasGradientBorder ? AppDimensions.avatarBorderWidth : 0.0;

    Widget avatar = Container(
      width: avatarSize + (borderWidth * 2),
      height: avatarSize + (borderWidth * 2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasGradientBorder ? AppColors.primaryGradient : null,
      ),
      child: Container(
        margin: EdgeInsets.all(borderWidth),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
        ),
        child: ClipOval(
          child: _buildAvatarContent(avatarSize),
        ),
      ),
    );

    if (showOnlineStatus) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: AppDimensions.onlineIndicatorSize,
              height: AppDimensions.onlineIndicatorSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isOnline ? AppColors.onlineStatus : AppColors.offlineStatus,
                border: Border.all(
                  color: AppColors.surface,
                  width: 2,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  /// Build avatar content with image or placeholder
  Widget _buildAvatarContent(double size) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPlaceholder(size);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(size);
        },
      );
    }

    return _buildPlaceholder(size);
  }

  /// Build placeholder with initials or default icon
  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: _buildInitials(size),
      ),
    );
  }

  /// Build initials from name or default icon
  Widget _buildInitials(double size) {
    if (name != null && name!.isNotEmpty) {
      final initials = _getInitials(name!);
      final fontSize = size * 0.4;

      return Text(
        initials,
        style: TextStyle(
          color: AppColors.onPrimary,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Icon(
      Icons.person,
      color: AppColors.onPrimary,
      size: size * 0.6,
    );
  }

  /// Get initials from name (first letter of first two words)
  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.isEmpty) return '';

    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Get avatar size based on size enum
  double _getAvatarSize() {
    switch (size) {
      case AvatarSize.small:
        return AppDimensions.avatarSizeSmall;
      case AvatarSize.medium:
        return AppDimensions.avatarSizeMedium;
      case AvatarSize.large:
        return AppDimensions.avatarSizeLarge;
      case AvatarSize.extraLarge:
        return AppDimensions.avatarSizeXl;
    }
  }
}
