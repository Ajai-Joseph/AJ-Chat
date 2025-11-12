import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

/// Message bubble component for chat messages
/// Supports sent and received message variants with different styling
class MessageBubble extends StatelessWidget {
  final String message;
  final DateTime timestamp;
  final bool isSent;
  final bool showTimestamp;

  const MessageBubble({
    super.key,
    required this.message,
    required this.timestamp,
    required this.isSent,
    this.showTimestamp = true,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxWidth = screenWidth * AppDimensions.messageBubbleMaxWidth;

    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppDimensions.spacingXs,
      ),
      child: Column(
        crossAxisAlignment:
            isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            decoration: BoxDecoration(
              gradient: isSent ? AppColors.messageGradient : null,
              color: isSent ? null : AppColors.receivedMessageBackground,
              borderRadius: _getBorderRadius(),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.messageBubblePadding,
              vertical: AppDimensions.messageBubblePadding,
            ),
            child: Text(
              message,
              style: isSent
                  ? AppTextStyles.messageSent
                  : AppTextStyles.messageReceived,
            ),
          ),
          if (showTimestamp) ...[
            const SizedBox(height: AppDimensions.spacingXs),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingXs,
              ),
              child: Text(
                _formatTimestamp(timestamp),
                style: AppTextStyles.messageTimestamp,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get border radius with asymmetric corners
  /// Sent messages have small radius on bottom-right
  /// Received messages have small radius on bottom-left
  BorderRadius _getBorderRadius() {
    if (isSent) {
      return const BorderRadius.only(
        topLeft: Radius.circular(AppDimensions.messageBubbleRadius),
        topRight: Radius.circular(AppDimensions.messageBubbleRadius),
        bottomLeft: Radius.circular(AppDimensions.messageBubbleRadius),
        bottomRight: Radius.circular(AppDimensions.messageBubbleRadiusSmall),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(AppDimensions.messageBubbleRadius),
        topRight: Radius.circular(AppDimensions.messageBubbleRadius),
        bottomLeft: Radius.circular(AppDimensions.messageBubbleRadiusSmall),
        bottomRight: Radius.circular(AppDimensions.messageBubbleRadius),
      );
    }
  }

  /// Format timestamp to display time
  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      // Today: show time only
      return DateFormat('HH:mm').format(dateTime);
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Yesterday
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else if (now.difference(dateTime).inDays < 7) {
      // Within a week: show day and time
      return DateFormat('EEE HH:mm').format(dateTime);
    } else {
      // Older: show date and time
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }
}
