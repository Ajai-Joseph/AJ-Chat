# Implementation Plan

- [x] 1. Create theme foundation and configuration files





  - Create `lib/theme/app_colors.dart` with complete color palette including primary gradient colors, surface colors, message colors, and status colors
  - Create `lib/theme/app_text_styles.dart` with all typography definitions for headlines, body text, buttons, and captions
  - Create `lib/theme/app_dimensions.dart` with spacing constants, border radius values, and sizing specifications
  - Create `lib/theme/app_theme.dart` that combines all theme elements into a cohesive ThemeData configuration with Material Design 3 settings
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 12.1, 12.2, 12.3, 12.5_

- [x] 2. Build reusable modern UI components






  - [x] 2.1 Create modern button component

    - Implement `lib/widgets/modern_button.dart` with primary, secondary, and outlined button variants
    - Add gradient support for primary buttons
    - Include proper padding, rounded corners, and elevation
    - Add ripple effect and press states
    - _Requirements: 4.3, 10.1, 10.3_
  
  - [x] 2.2 Create modern text field component


    - Implement `lib/widgets/modern_text_field.dart` with outlined style and floating labels
    - Add support for prefix icons, suffix icons, and password visibility toggle
    - Include error state styling with red borders and error messages
    - Implement focus state with accent color highlighting
    - _Requirements: 4.1, 4.4, 11.3_
  
  - [x] 2.3 Create message bubble component


    - Implement `lib/widgets/message_bubble.dart` with sent and received message variants
    - Add gradient background for sent messages and light gray for received messages
    - Include proper padding, rounded corners with asymmetric radius, and max width constraints
    - Add timestamp display below bubbles with proper formatting
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6_
  
  - [x] 2.4 Create user avatar component


    - Implement `lib/widgets/user_avatar.dart` with circular shape and network image support
    - Add optional online status indicator with colored badge
    - Include gradient border option for featured users
    - Add placeholder for loading and error states
    - _Requirements: 5.5, 10.1_

- [x] 3. Modernize splash screen





  - Update `lib/splashScreen.dart` to use gradient background from theme
  - Implement logo scale animation from 0.8 to 1.0 over 600ms with fade-in effect
  - Add app name text with fade-in animation delayed by 200ms
  - Add modern circular loading indicator at bottom with fade-in delayed by 400ms
  - Apply modern typography from theme for app name
  - Fix file naming to `splash_screen.dart` following Dart conventions
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 2.1_

- [x] 4. Modernize authentication screens





  - [x] 4.1 Update login screen


    - Refactor `lib/login.dart` to use gradient header section occupying 20% of screen height
    - Replace existing form with elevated white card container using modern styling
    - Implement ModernTextField components for email and password with appropriate icons
    - Add password visibility toggle icon to password field
    - Replace buttons with ModernButton components using gradient primary style
    - Add smooth page transition animation when navigating to sign up
    - Fix state management issues by converting to StatefulWidget if needed
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.6, 2.1_
  
  - [x] 4.2 Update sign up screen


    - Refactor `lib/signUp.dart` to match login screen structure with gradient header
    - Update profile photo picker to use modern card design with camera icon overlay
    - Implement bottom sheet with modern styling for camera/gallery selection
    - Replace form fields with ModernTextField components
    - Update sign up button to use ModernButton with gradient style
    - Add image picker UI improvements with dashed border and better visual feedback
    - Fix file naming to `sign_up_screen.dart` following Dart conventions
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 2.1_
  
  - [x] 4.3 Update password reset screen


    - Refactor `lib/resetPassword.dart` to match authentication screen design pattern
    - Apply gradient header and card-based form layout
    - Replace text field with ModernTextField component
    - Update button to use ModernButton component
    - Add proper animations and transitions
    - _Requirements: 4.1, 4.2, 4.3, 2.1_

- [x] 5. Modernize home screen





  - [x] 5.1 Update app bar design


    - Refactor app bar in `lib/home.dart` to use gradient background from theme
    - Update menu and logout icons with proper sizing and colors
    - Add elevation shadow to app bar
    - Ensure proper spacing and alignment of app bar elements
    - _Requirements: 5.6, 10.1, 10.2, 10.3_
  
  - [x] 5.2 Modernize horizontal user list

    - Update horizontal user list to use UserAvatar component with gradient borders
    - Add online status indicators with green dot badges
    - Implement smooth horizontal scrolling with proper momentum
    - Add user name labels below avatars with modern typography
    - Apply proper spacing between avatar items
    - _Requirements: 5.1, 5.5, 10.1_
  
  - [x] 5.3 Update search bar design

    - Redesign search TextField with rounded corners (24dp radius)
    - Add light gray background with subtle elevation
    - Implement search icon on left and clear icon on right
    - Add smooth focus animations with accent color
    - Ensure proper padding and sizing
    - _Requirements: 5.2, 10.1, 10.2_
  
  - [x] 5.4 Modernize conversation list

    - Update conversation list items to use card-based design with elevation
    - Implement UserAvatar component for profile pictures
    - Apply modern typography for names and last messages
    - Add timestamps on right side with proper formatting
    - Implement ripple effect on tap with smooth animation
    - Add proper spacing and dividers between items
    - Ensure smooth scrolling performance
    - _Requirements: 5.3, 5.4, 2.4, 10.1_
  
  - [x] 5.5 Update navigation drawer

    - Redesign drawer header with gradient background and modern typography
    - Update drawer list items with proper icons and spacing
    - Apply elevation and shadows to drawer
    - Set appropriate drawer width for modern mobile design
    - Add ripple effects to drawer items
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 10.1_

- [x] 6. Modernize chat screen






  - [x] 6.1 Update chat app bar

    - Refactor app bar in `lib/chat.dart` to use gradient or solid background from theme
    - Implement UserAvatar component for receiver profile picture
    - Update video call icon with modern styling and proper sizing
    - Add back button with proper navigation
    - Ensure proper spacing and alignment
    - _Requirements: 10.1, 10.2, 10.3, 10.4_
  

  - [x] 6.2 Implement modern message bubbles





    - Replace existing message containers with MessageBubble component
    - Apply gradient background for sent messages and light gray for received
    - Implement asymmetric rounded corners (small radius on sender side)
    - Add proper max width constraints (70% of screen)
    - Ensure text wrapping works correctly within bubbles
    - Add fade-in animation for new messages
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 6.6, 2.3_

  
  - [x] 6.3 Update message input area





    - Redesign message input TextField with rounded corners and light background
    - Add subtle elevation to input container
    - Implement circular send button with primary color and icon
    - Ensure multiline text support with proper expansion
    - Add proper padding and spacing around input area
    - Apply accent color to send button for visual emphasis

    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 10.1_
  
  - [x] 6.4 Add message animations





    - Implement fade-in animation for incoming messages
    - Add smooth scroll-to-bottom when new messages arrive
    - Ensure animations maintain 60fps performance
    - _Requirements: 2.3, 2.5_

- [x] 7. Modernize video call screen





  - Update `lib/call_screen.dart` app bar with modern styling and proper icon sizing
  - Redesign video call control buttons with circular backgrounds and modern icons
  - Add semi-transparent overlay for controls
  - Update video feed containers with rounded corners
  - Implement modern connection status indicators with loading animations
  - Add smooth transitions between video states (connecting, connected, calling)
  - Update participant name overlay with modern typography
  - Ensure proper aspect ratios for video feeds
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 10.1, 10.2, 10.3_

- [x] 8. Implement global animations and transitions





  - Add page transition animations for all navigation routes using custom PageRouteBuilder
  - Implement hero animations for user avatars between screens
  - Add ripple effects to all interactive elements (buttons, list items, cards)
  - Ensure all animations run at 60fps without jank
  - Add smooth drawer open/close animations
  - _Requirements: 2.1, 2.2, 2.4, 2.5_

- [x] 9. Improve error handling and feedback UI





  - Update toast messages throughout app to use modern styling with rounded corners
  - Implement custom toast widget with appropriate colors for success, error, and info states
  - Update loading indicators to use primary color from theme
  - Add semi-transparent overlays for blocking operations with modern circular progress
  - Implement inline form validation with error messages and icons
  - Update all Fluttertoast calls to use consistent modern styling
  - _Requirements: 11.1, 11.2, 11.3, 11.4_

- [x] 10. Update main app configuration





  - Update `lib/main.dart` to use the new AppTheme configuration
  - Apply Material Design 3 settings (useMaterial3: true)
  - Configure theme mode support (light/dark if implementing)
  - Ensure theme is applied globally to MaterialApp
  - Fix any deprecated widget warnings
  - _Requirements: 1.1, 12.4, 12.5_

- [x] 11. Code cleanup and optimization





  - Fix all linting issues and warnings identified in diagnostic output
  - Convert StatelessWidget to StatefulWidget where state management is needed
  - Add proper type annotations to all variables
  - Fix async gap issues with BuildContext by adding mounted checks
  - Remove unused imports across all files
  - Rename files to follow snake_case convention (signUp.dart → sign_up_screen.dart, etc.)
  - Add const constructors where applicable for performance
  - Fix validator functions to return null instead of void
  - Update deprecated widgets (WillPopScope → PopScope)
  - _Requirements: 12.5_

- [ ]* 12. Testing and quality assurance
  - [ ]* 12.1 Visual testing
    - Capture screenshots of all screens and compare against design specifications
    - Test on multiple screen sizes (small, medium, large phones)
    - Verify color accuracy and contrast ratios
    - Check spacing and alignment consistency
    - _Requirements: 1.3, 1.4, 1.5_
  
  - [ ]* 12.2 Animation performance testing
    - Profile animation frame rates using Flutter DevTools
    - Identify and fix any dropped frames or jank
    - Verify smooth scrolling in all list views
    - Test animation timing and easing curves
    - _Requirements: 2.5_
  
  - [ ]* 12.3 Integration testing
    - Test complete authentication flow with new UI
    - Test messaging flow from home to chat screen
    - Test video call initiation and controls
    - Verify navigation transitions work correctly
    - Test search functionality with new UI
    - _Requirements: 2.1_
  
  - [ ]* 12.4 Accessibility testing
    - Verify color contrast ratios meet WCAG AA standards
    - Test with screen reader support
    - Ensure touch targets meet minimum size requirements (48dp)
    - Test text scaling at different system font sizes
    - _Requirements: 10.5_
