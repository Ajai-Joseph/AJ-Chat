import 'package:aj_chat/chat.dart';
import 'package:aj_chat/login.dart';
import 'package:aj_chat/theme/app_colors.dart';
import 'package:aj_chat/theme/app_dimensions.dart';
import 'package:aj_chat/theme/app_text_styles.dart';
import 'package:aj_chat/utils/toast_helper.dart';
import 'package:aj_chat/widgets/user_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  FirebaseAuth auth = FirebaseAuth.instance;
  int? searchKeyLength;
  TextEditingController searchController = TextEditingController();
  late bool search;
  String? searchKey;
  late String userId;
  @override
  void initState() {
    search = false;
    userId = auth.currentUser!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: globalKey,
      drawer: _buildDrawer(context),
      body: Column(
        children: [
          // Modern App Bar with gradient
          _buildModernAppBar(context),
          // Horizontal user list
          _buildHorizontalUserList(),
          // Search bar and conversation list
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusXl),
                  topRight: Radius.circular(AppDimensions.radiusXl),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppDimensions.spacingM),
                  // Modern search bar
                  _buildModernSearchBar(),
                  const SizedBox(height: AppDimensions.spacingM),
                  // Conversation list
                  Expanded(
                    child: _buildConversationList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build modern app bar with gradient background
  Widget _buildModernAppBar(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: SafeArea(
        bottom: false,
        child: Container(
          height: AppDimensions.appBarHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingS,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  globalKey.currentState!.openDrawer();
                },
                icon: const Icon(
                  Icons.menu,
                  color: AppColors.onPrimary,
                  size: AppDimensions.iconSizeLarge,
                ),
                tooltip: 'Menu',
              ),
              const Text(
                'AJ Chat',
                style: AppTextStyles.appBarTitle,
              ),
              IconButton(
                onPressed: () => _handleLogout(context),
                icon: const Icon(
                  Icons.logout,
                  color: AppColors.onPrimary,
                  size: AppDimensions.iconSizeMedium,
                ),
                tooltip: 'Logout',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle logout with proper async handling
  Future<void> _handleLogout(BuildContext context) async {
    try {
      final sharedPreference = await SharedPreferences.getInstance();
      await sharedPreference.clear();
      await auth.signOut();
      
      if (!mounted) return;
      
      // Use the context from the widget tree, not the parameter
      if (!context.mounted) return;
      
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ToastHelper.showError("Failed to logout");
    }
  }

  /// Build horizontal user list with modern styling
  Widget _buildHorizontalUserList() {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      padding: const EdgeInsets.only(
        left: AppDimensions.paddingM,
        bottom: AppDimensions.paddingM,
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("Users").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.onPrimary,
              ),
            );
          }

          final users = snapshot.data!.docs
              .where((doc) => doc['Id'] != userId)
              .toList();

          if (users.isEmpty) {
            return const Center(
              child: Text(
                'No users available',
                style: TextStyle(color: AppColors.onPrimary),
              ),
            );
          }

          return ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: users.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppDimensions.spacingM),
            itemBuilder: (context, index) {
              final user = users[index];
              return _buildUserAvatarItem(user);
            },
          );
        },
      ),
    );
  }

  /// Build individual user avatar item
  Widget _buildUserAvatarItem(QueryDocumentSnapshot user) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChatScreen(receiverId: user['Id']),
          ),
        );
      },
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAvatar(
              imageUrl: user['Image'],
              name: user['Name'],
              size: AvatarSize.large,
              hasGradientBorder: true,
              showOnlineStatus: true,
              isOnline: true, // TODO: Implement real online status
            ),
            const SizedBox(height: AppDimensions.spacingXs),
            Text(
              user['Name'],
              style: AppTextStyles.caption.copyWith(
                color: AppColors.onPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build modern search bar
  Widget _buildModernSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingM,
      ),
      child: Container(
        height: AppDimensions.searchBarHeight,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.searchBarRadius),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Search conversations...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textSecondary,
              size: AppDimensions.iconSizeMedium,
            ),
            suffixIcon: search
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        searchController.clear();
                        search = false;
                      });
                    },
                    icon: const Icon(
                      Icons.clear,
                      color: AppColors.textSecondary,
                      size: AppDimensions.iconSizeMedium,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingM,
              vertical: AppDimensions.paddingM,
            ),
          ),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                search = false;
              } else {
                searchKey = value;
                searchKeyLength = value.length;
                search = true;
              }
            });
          },
        ),
      ),
    );
  }

  /// Build conversation list
  Widget _buildConversationList() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: search ? _buildSearchResults() : _buildRecentConversations(),
    );
  }

  /// Build recent conversations list
  Widget _buildRecentConversations() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("Last Message")
          .doc(userId)
          .collection('Message')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final conversations = snapshot.data!.docs
            .where((doc) => doc['Id'] != userId)
            .toList();

        if (conversations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'No conversations yet',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: conversations.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppDimensions.spacingS),
          itemBuilder: (context, index) {
            final conversation = conversations[index];
            return _buildConversationCard(conversation);
          },
        );
      },
    );
  }

  /// Build search results list
  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection("Users").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        }

        final users = snapshot.data!.docs.where((doc) {
          if (doc['Id'] == userId) return false;
          
          final name = doc['Name'].toString();
          if (searchKeyLength! <= name.length) {
            return name.substring(0, searchKeyLength).toLowerCase() ==
                searchKey!.toLowerCase();
          }
          return false;
        }).toList();

        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'No users found',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
          ),
          physics: const BouncingScrollPhysics(),
          itemCount: users.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: AppDimensions.spacingS),
          itemBuilder: (context, index) {
            final user = users[index];
            return _buildConversationCard(user);
          },
        );
      },
    );
  }

  /// Build conversation card with modern styling
  Widget _buildConversationCard(QueryDocumentSnapshot data) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (search) {
            searchController.clear();
            setState(() {
              search = false;
            });
          }
          FocusScope.of(context).unfocus();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ChatScreen(receiverId: data['Id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppDimensions.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              UserAvatar(
                imageUrl: data['Image'],
                name: data['Name'],
                size: AvatarSize.medium,
                showOnlineStatus: true,
                isOnline: true, // TODO: Implement real online status
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['Name'],
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (data.data().toString().contains('Last Message'))
                      const SizedBox(height: AppDimensions.spacingXs),
                    if (data.data().toString().contains('Last Message'))
                      Text(
                        data['Last Message'] ?? '',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              if (data.data().toString().contains('Time'))
                Text(
                  data['Time'] ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build modern navigation drawer
  Widget _buildDrawer(BuildContext context) {
    return SizedBox(
      width: AppDimensions.drawerWidth,
      child: Drawer(
        child: Column(
          children: [
            // Modern drawer header with gradient
            Container(
              width: double.infinity,
              height: AppDimensions.drawerHeaderHeight,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingM),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Developer Contact',
                        style: TextStyle(
                          color: AppColors.onPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXs),
                      Text(
                        'Get in touch',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Drawer items
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppDimensions.paddingM,
              ),
              child: Column(
                children: [
                  _buildDrawerItem(
                    icon: Icons.phone,
                    title: '+91 9497308477',
                    onTap: () {
                      // TODO: Implement phone call functionality
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.email,
                    title: 'ajaijoseph363@gmail.com',
                    onTap: () {
                      // TODO: Implement email functionality
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build drawer list item
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingM,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.primary,
                size: AppDimensions.iconSizeMedium,
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
