# Design Document

## Overview

This design document outlines the architectural approach and implementation strategy for modernizing the AJ Chat Flutter application. The redesign focuses on implementing Material Design 3 principles, creating a cohesive visual language, and enhancing user experience through modern UI patterns, smooth animations, and improved component design. The implementation will maintain all existing functionality while transforming the visual presentation layer.

## Architecture

### Design System Architecture

The modernization will follow a layered architecture approach:

1. **Theme Layer**: Centralized theme configuration defining colors, typography, and component themes
2. **Component Layer**: Reusable UI components built with modern styling
3. **Screen Layer**: Individual screens composed of themed components
4. **Animation Layer**: Transition and micro-interaction animations

### Theme Configuration Structure

```
lib/
├── theme/
│   ├── app_theme.dart          # Main theme configuration
│   ├── app_colors.dart         # Color palette definitions
│   ├── app_text_styles.dart    # Typography definitions
│   └── app_dimensions.dart     # Spacing and sizing constants
├── widgets/
│   ├── modern_button.dart      # Reusable button component
│   ├── modern_text_field.dart  # Reusable input field component
│   ├── message_bubble.dart     # Chat message bubble component
│   └── user_avatar.dart        # Profile avatar component
└── screens/
    ├── splash_screen.dart
    ├── login_screen.dart
    ├── sign_up_screen.dart
    ├── home_screen.dart
    └── chat_screen.dart
```

## Components and Interfaces

### 1. Theme System

#### Color Palette

**Primary Colors:**
- Primary: Deep purple/blue gradient (#6366F1 to #8B5CF6)
- Primary Container: Light purple (#EDE9FE)
- On Primary: White (#FFFFFF)

**Secondary Colors:**
- Secondary: Teal/cyan (#14B8A6)
- Secondary Container: Light teal (#CCFBF1)
- On Secondary: Dark gray (#1F2937)

**Surface Colors:**
- Surface: White (#FFFFFF)
- Surface Variant: Light gray (#F3F4F6)
- Background: Very light gray (#F9FAFB)
- On Surface: Dark gray (#111827)

**Message Colors:**
- Sent Message: Primary gradient
- Received Message: Light gray (#E5E7EB)
- Message Text (Sent): White
- Message Text (Received): Dark gray

**Status Colors:**
- Success: Green (#10B981)
- Error: Red (#EF4444)
- Warning: Amber (#F59E0B)
- Info: Blue (#3B82F6)

#### Typography

**Headline Styles:**
- H1: 32sp, Bold, Primary color
- H2: 24sp, SemiBold, On Surface
- H3: 20sp, SemiBold, On Surface

**Body Styles:**
- Body Large: 16sp, Regular, On Surface
- Body Medium: 14sp, Regular, On Surface
- Body Small: 12sp, Regular, On Surface Variant

**Button Styles:**
- Button Text: 16sp, SemiBold, On Primary

**Caption Styles:**
- Caption: 12sp, Regular, On Surface Variant
- Overline: 10sp, Medium, On Surface Variant

#### Spacing System

- Extra Small: 4dp
- Small: 8dp
- Medium: 16dp
- Large: 24dp
- Extra Large: 32dp
- XXL: 48dp

#### Border Radius

- Small: 8dp
- Medium: 12dp
- Large: 16dp
- Extra Large: 24dp
- Circular: 999dp

### 2. Splash Screen Design

**Visual Structure:**
- Gradient background (Primary to Secondary)
- Centered logo with scale animation
- App name with fade-in animation
- Loading indicator at bottom
- Smooth transition to next screen

**Animation Sequence:**
1. Logo scales from 0.8 to 1.0 over 600ms
2. Logo fades in simultaneously
3. App name fades in after 200ms delay
4. Loading indicator appears after 400ms delay

### 3. Authentication Screens Design

#### Login Screen

**Layout:**
- Gradient header section (20% of screen height)
- White card container with elevation
- Outlined text fields with floating labels
- Primary gradient button for "Sign In"
- Text button for "Forgot Password"
- Secondary outlined button for "Sign Up"

**Visual Elements:**
- App logo/name in header
- Email field with email icon
- Password field with visibility toggle icon
- Rounded corners on all elements
- Subtle shadows on card

#### Sign Up Screen

**Layout:**
- Similar structure to login screen
- Profile photo picker with camera icon overlay
- Name, email, and password fields
- Large primary button for "Sign Up"

**Profile Photo Picker:**
- Circular avatar with dashed border
- Camera icon overlay
- Bottom sheet with modern card design
- Camera and gallery options with icons

### 4. Home Screen Design

**Layout Structure:**
- Modern app bar with gradient background
- Horizontal scrollable user list (stories-style)
- Search bar with rounded corners
- Conversation list with card design
- Floating action button (optional)

**App Bar:**
- Menu icon (left)
- App title (center)
- Logout icon (right)
- Gradient or solid color background
- Elevation shadow

**User List (Horizontal):**
- Circular avatars with gradient borders
- User names below avatars
- Horizontal scroll with momentum
- Online status indicator (green dot)

**Search Bar:**
- Rounded corners (24dp radius)
- Search icon (left)
- Clear icon (right, when active)
- Light gray background
- Subtle elevation

**Conversation List:**
- Card-based list items
- Avatar on left
- Name and last message
- Timestamp on right
- Dividers between items
- Ripple effect on tap

### 5. Chat Screen Design

**Layout Structure:**
- Modern app bar with user info
- Message list area
- Message input area at bottom

**App Bar:**
- Back button (left)
- User avatar and name (center-left)
- Video call icon (right)
- Gradient or solid background

**Message Bubbles:**

*Sent Messages:*
- Aligned right
- Primary gradient background
- White text
- Rounded corners (16dp, with small radius on bottom-right)
- Timestamp below (right-aligned)
- Max width: 70% of screen

*Received Messages:*
- Aligned left
- Light gray background
- Dark text
- Rounded corners (16dp, with small radius on bottom-left)
- Timestamp below (left-aligned)
- Max width: 70% of screen

**Message Input Area:**
- Rounded text field container
- Light background with border
- Multiline support
- Send button (circular, primary color)
- Icon-only send button
- Elevation on container

### 6. Video Call Screen Design

**Layout:**
- Full-screen video area
- Floating controls overlay
- Participant info overlay
- Local video preview (bottom-right corner)

**Controls:**
- Modern icon buttons with circular backgrounds
- Mute/unmute microphone
- Enable/disable video
- End call (red, prominent)
- Semi-transparent background overlay

**Video Containers:**
- Rounded corners on video feeds
- Participant name overlay at bottom
- Connection status indicator
- Smooth transitions between states

### 7. Navigation Drawer Design

**Structure:**
- Modern header with gradient
- User profile section (optional)
- List items with icons
- Dividers between sections

**Header:**
- Gradient background
- App branding
- Height: 120dp

**List Items:**
- Icon on left
- Text label
- Ripple effect on tap
- Proper spacing and padding

## Data Models

No changes to existing data models are required. The modernization focuses on the presentation layer only. Existing Firebase data structures remain unchanged:

- Users collection
- Chats collection
- Messages subcollection
- Last Message collection

## Error Handling

### Visual Error Feedback

**Toast Messages:**
- Modern styling with rounded corners
- Appropriate background colors (error: red, success: green)
- White text with proper contrast
- Bottom positioning with margin
- Auto-dismiss after 3 seconds

**Loading States:**
- Circular progress indicators with primary color
- Centered positioning
- Semi-transparent overlay for blocking operations
- Smooth fade-in/out animations

**Form Validation:**
- Inline error messages below fields
- Red error text
- Error icon next to message
- Field border color changes to error color

## Testing Strategy

### Visual Testing

1. **Screenshot Testing:**
   - Capture screenshots of all screens in both light and dark modes
   - Compare against design specifications
   - Verify color accuracy and spacing

2. **Responsive Testing:**
   - Test on multiple screen sizes (small, medium, large)
   - Verify layout adapts properly
   - Check text scaling and readability

3. **Animation Testing:**
   - Verify smooth 60fps animations
   - Test animation timing and easing
   - Check for jank or stuttering

### Component Testing

1. **Theme Testing:**
   - Verify theme values are applied consistently
   - Test theme switching (if implemented)
   - Check color contrast ratios for accessibility

2. **Widget Testing:**
   - Test custom components in isolation
   - Verify proper rendering
   - Check interaction states (pressed, focused, disabled)

### Integration Testing

1. **Navigation Testing:**
   - Test screen transitions
   - Verify navigation animations
   - Check back button behavior

2. **User Flow Testing:**
   - Test complete authentication flow
   - Test messaging flow
   - Test video call initiation

### Performance Testing

1. **Animation Performance:**
   - Monitor frame rates during animations
   - Check for dropped frames
   - Verify smooth scrolling

2. **Build Performance:**
   - Measure widget rebuild counts
   - Optimize unnecessary rebuilds
   - Check memory usage

## Implementation Approach

### Phase 1: Theme Foundation
- Create theme configuration files
- Define color palette
- Define typography system
- Set up spacing constants

### Phase 2: Reusable Components
- Build modern button component
- Build modern text field component
- Build message bubble component
- Build user avatar component

### Phase 3: Screen Modernization
- Update splash screen
- Update authentication screens
- Update home screen
- Update chat screen
- Update video call screen

### Phase 4: Polish and Refinement
- Add animations and transitions
- Refine spacing and alignment
- Test on multiple devices
- Fix any visual inconsistencies

## Design Decisions and Rationales

### Material Design 3 Choice
Material Design 3 provides a modern, well-documented design system that works seamlessly with Flutter. It offers improved theming capabilities and updated components that align with current design trends.

### Gradient Usage
Gradients add visual interest and depth to the interface. They're used sparingly in headers and primary actions to create focal points without overwhelming the user.

### Card-Based Design
Cards provide clear visual separation between content items and create a sense of hierarchy. They work well for conversation lists and form containers.

### Rounded Corners
Rounded corners create a softer, more approachable aesthetic compared to sharp corners. They're a hallmark of modern mobile design.

### Color Contrast
All color combinations meet WCAG AA standards for accessibility, ensuring readability for all users.

### Animation Timing
Animation durations are kept between 200-600ms for optimal perceived performance. Longer animations feel sluggish, while shorter ones may be jarring.

### Component Reusability
Creating reusable components ensures consistency across the app and makes future updates easier to implement.
