import 'dart:developer';

import 'package:aj_chat/call_screen.dart';
import 'package:aj_chat/theme/app_colors.dart';
import 'package:aj_chat/theme/app_dimensions.dart';
import 'package:aj_chat/utils/snackbar_helper.dart';
import 'package:aj_chat/widgets/message_bubble.dart';
import 'package:aj_chat/widgets/user_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  final String receiverId;

  const ChatScreen({super.key, required this.receiverId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _receiverImage = '';
  String _receiverName = '';
  String _senderName = '';
  String _senderImage = '';
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadSenderInfo();
    _messageController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() {
        _isTyping = hasText;
      });
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSenderInfo() async {
    try {
      final doc = await _firestore
          .collection("Users")
          .doc(_auth.currentUser!.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _senderImage = doc.data()!['Image'] ?? '';
          _senderName = doc.data()!['Name'] ?? '';
        });
      }
    } catch (e) {
      log('Error loading sender info: $e');
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildModernAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(),
          ),
          _buildMessageInputArea(),
        ],
      ),
    );
  }

  /// Build modern app bar with gradient background
  PreferredSizeWidget _buildModernAppBar(BuildContext context) {
    return AppBar(
      elevation: 2,
      shadowColor: AppColors.shadow,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection("Users").doc(widget.receiverId).get(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>;
            _receiverImage = data['Image'] ?? '';
            _receiverName = data['Name'] ?? '';

            return Row(
              children: [
                UserAvatar(
                  imageUrl: _receiverImage,
                  name: _receiverName,
                  size: AvatarSize.small,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _receiverName,
                        style: const TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        'online',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.call,
            color: AppColors.onPrimary,
            size: 24,
          ),
          onPressed: () {
            // TODO: Implement audio call
          },
          tooltip: 'Audio call',
        ),
        IconButton(
          icon: const Icon(
            Icons.videocam_rounded,
            color: AppColors.onPrimary,
            size: 28,
          ),
          onPressed: () => _initiateVideoCall(context),
          tooltip: 'Video call',
        ),
        PopupMenuButton<String>(
          icon: const Icon(
            Icons.more_vert,
            color: AppColors.onPrimary,
          ),
          onSelected: (value) {
            // TODO: Handle menu actions
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_contact',
              child: Text('View contact'),
            ),
            const PopupMenuItem(
              value: 'media',
              child: Text('Media, links, and docs'),
            ),
            const PopupMenuItem(
              value: 'search',
              child: Text('Search'),
            ),
            const PopupMenuItem(
              value: 'mute',
              child: Text('Mute notifications'),
            ),
            const PopupMenuItem(
              value: 'wallpaper',
              child: Text('Wallpaper'),
            ),
          ],
        ),
      ],
    );
  }

  /// Build message list with modern message bubbles
  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection("Chats")
          .doc(_auth.currentUser!.uid + widget.receiverId)
          .collection("Messages")
          .orderBy("Time", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading messages',
              style: TextStyle(color: AppColors.error),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final messages = snapshot.data!.docs;

        if (messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  'Start the conversation!',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        // Scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            _scrollController.jumpTo(0);
          }
        });

        return ListView.builder(
          controller: _scrollController,
          reverse: true,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.spacingS,
          ),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final messageDoc = messages[index];
            final messageData = messageDoc.data() as Map<String, dynamic>;
            final message = messageData['Message'] ?? '';
            final senderId = messageData['SenderId'] ?? '';
            final timestamp = DateTime.parse(messageData['Time']);
            final isSent = senderId == _auth.currentUser!.uid;

            // Check if we need to show date separator
            bool showDateSeparator = false;
            String? dateLabel;
            
            if (index == messages.length - 1) {
              // Always show date for the oldest message
              showDateSeparator = true;
              dateLabel = _getDateLabel(timestamp);
            } else {
              // Check if date changed from next message
              final nextMessageData = messages[index + 1].data() as Map<String, dynamic>;
              final nextTimestamp = DateTime.parse(nextMessageData['Time']);
              
              if (!_isSameDay(timestamp, nextTimestamp)) {
                showDateSeparator = true;
                dateLabel = _getDateLabel(timestamp);
              }
            }

            return Column(
              children: [
                if (showDateSeparator) _buildDateSeparator(dateLabel!),
                Align(
                  alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                  child: MessageBubble(
                    key: ValueKey(messageDoc.id),
                    message: message,
                    timestamp: timestamp,
                    isSent: isSent,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Build modern message input area
  Widget _buildMessageInputArea() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                  border: Border.all(
                    color: AppColors.border,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Emoji button (always visible)
                    IconButton(
                      icon: const Icon(
                        Icons.emoji_emotions_outlined,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                      onPressed: () {
                        // TODO: Show emoji picker
                      },
                      tooltip: 'Emoji',
                      padding: const EdgeInsets.all(8),
                    ),
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        keyboardType: TextInputType.multiline,
                        maxLines: 5,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 16,
                        ),
                        decoration: const InputDecoration(
                          hintText: "Message",
                          hintStyle: TextStyle(
                            color: AppColors.onSurfaceVariant,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 10,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                      ),
                    ),
                    // Show attachment and camera only when not typing
                    if (!_isTyping) ...[
                      IconButton(
                        icon: const Icon(
                          Icons.attach_file,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                        onPressed: () {
                          _showAttachmentOptions(context);
                        },
                        tooltip: 'Attach',
                        padding: const EdgeInsets.all(8),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.camera_alt_outlined,
                          color: AppColors.textSecondary,
                          size: 24,
                        ),
                        onPressed: () {
                          // TODO: Open camera
                        },
                        tooltip: 'Camera',
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            // Send/Voice button
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (_isTyping) {
                      _sendMessage();
                    }
                  },
                  onLongPress: () {
                    if (!_isTyping) {
                      // TODO: Start voice recording
                    }
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Icon(
                      _isTyping ? Icons.send_rounded : Icons.mic,
                      color: AppColors.onPrimary,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show attachment options bottom sheet
  void _showAttachmentOptions(BuildContext context) {
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
            // Attachment options grid
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              mainAxisSpacing: AppDimensions.spacingM,
              crossAxisSpacing: AppDimensions.spacingM,
              children: [
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: const Color(0xFF7F66FF),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Pick document
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: const Color(0xFFD946EF),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Pick from gallery
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.headphones,
                  label: 'Audio',
                  color: const Color(0xFFF97316),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Pick audio
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Share location
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.person,
                  label: 'Contact',
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Share contact
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build attachment option item
  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build date separator
  Widget _buildDateSeparator(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingXs,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get date label (Today, Yesterday, or date)
  String _getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(messageDate).inDays < 7) {
      // Show day name for last 7 days
      const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return days[date.weekday - 1];
    } else {
      // Show date for older messages
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Initiate video call
  Future<void> _initiateVideoCall(BuildContext context) async {
    try {
      final email = _auth.currentUser!.email!;
      final username = email.split('@')[0];
      final token = await _fetchAccessToken(username, 'AJ-Chat-Test-Room');

      if (!mounted) return;
      if (!context.mounted) return;
      
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => VideoCallScreen(token: token),
        ),
      );
    } catch (e) {
      log('Error initiating video call: $e');
      if (!mounted) return;
      if (!context.mounted) return;
      
      SnackBarHelper.showError(context, 'Failed to start video call');
    }
  }

  /// Send message to Firestore
  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    final date = DateTime.now();

    try {
      // Add message to both chat documents
      final messageData = {
        'Message': message,
        'Time': date.toString(),
        'SenderId': _auth.currentUser!.uid,
        'ReceiverId': widget.receiverId,
      };

      await Future.wait([
        _firestore
            .collection("Chats")
            .doc(_auth.currentUser!.uid + widget.receiverId)
            .collection("Messages")
            .add(messageData),
        _firestore
            .collection("Chats")
            .doc(widget.receiverId + _auth.currentUser!.uid)
            .collection("Messages")
            .add(messageData),
      ]);

      // Update last message for both users
      await Future.wait([
        _firestore
            .collection("Last Message")
            .doc(_auth.currentUser!.uid)
            .collection("Message")
            .doc(widget.receiverId)
            .set({
          'Last Message': message,
          'Name': _receiverName,
          'Image': _receiverImage,
          'Id': widget.receiverId,
        }),
        _firestore
            .collection("Last Message")
            .doc(widget.receiverId)
            .collection("Message")
            .doc(_auth.currentUser!.uid)
            .set({
          'Last Message': message,
          'Name': _senderName,
          'Image': _senderImage,
          'Id': _auth.currentUser!.uid,
        }),
      ]);
    } catch (e) {
      log('Error sending message: $e');
      if (!mounted) return;
      
      SnackBarHelper.showError(context, 'Failed to send message');
    }
  }

  /// Fetch access token for video call
  Future<String> _fetchAccessToken(
      String participantName, String roomName) async {
    final response = await http.get(
      Uri.parse(
          'http://192.168.29.73:3000/api/calls/getToken?name=$participantName&room=$roomName'),
    );

    if (response.statusCode == 200) {
      log(response.body.toString());
      return response.body.toString();
    } else {
      throw Exception('Failed to load access token');
    }
  }
}
