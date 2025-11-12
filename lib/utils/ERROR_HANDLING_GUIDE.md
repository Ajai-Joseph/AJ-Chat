# Error Handling and Feedback UI Guide

This guide explains how to use the modern error handling and feedback UI components in the AJ Chat application.

## Components Overview

### 1. ToastHelper (Fluttertoast-based)
Use for simple, non-blocking notifications that appear at the bottom of the screen.

**When to use:**
- Quick success/error messages
- Non-critical information
- Messages that don't require user interaction

**Usage:**
```dart
import 'package:aj_chat/utils/toast_helper.dart';

// Success message
ToastHelper.showSuccess("Login Successful");

// Error message
ToastHelper.showError("Failed to send message");

// Info message
ToastHelper.showInfo("New update available");

// Warning message
ToastHelper.showWarning("Please upload your photo");

// Custom message
ToastHelper.show(
  "Custom message",
  backgroundColor: Colors.blue,
  textColor: Colors.white,
);
```

### 2. SnackBarHelper
Use for contextual messages within a specific screen that may require user action.

**When to use:**
- Screen-specific feedback
- Messages with potential actions (undo, retry)
- More prominent notifications than toasts

**Usage:**
```dart
import 'package:aj_chat/utils/snackbar_helper.dart';

// Success snackbar
SnackBarHelper.showSuccess(context, "Message sent successfully");

// Error snackbar
SnackBarHelper.showError(context, "Failed to connect to video call");

// Info snackbar
SnackBarHelper.showInfo(context, "Connecting to server...");

// Warning snackbar
SnackBarHelper.showWarning(context, "Low storage space");
```

### 3. ModernToast (Custom Overlay)
Use for more customizable toast messages with animations.

**When to use:**
- Need custom animations
- Want more control over positioning
- Building custom notification systems

**Usage:**
```dart
import 'package:aj_chat/widgets/modern_toast.dart';

// Show custom toast
ModernToast.show(
  context,
  message: "Custom notification",
  type: ToastType.success,
  duration: Duration(seconds: 3),
);

// Convenience methods
ModernToast.success(context, "Operation successful");
ModernToast.error(context, "Operation failed");
ModernToast.info(context, "Information message");
ModernToast.warning(context, "Warning message");
```

### 4. LoadingOverlay
Use for blocking operations that require user to wait.

**When to use:**
- Long-running operations (file uploads, network requests)
- Operations that should block user interaction
- Need to show loading state with optional message

**Usage:**
```dart
import 'package:aj_chat/widgets/loading_overlay.dart';

// Show loading overlay
LoadingOverlay.show(context, message: "Uploading photo...");

// Perform async operation
await someAsyncOperation();

// Hide loading overlay
LoadingOverlay.hide();
```

**Example with try-catch:**
```dart
try {
  LoadingOverlay.show(context, message: "Processing...");
  await performOperation();
  LoadingOverlay.hide();
  ToastHelper.showSuccess("Operation completed");
} catch (e) {
  LoadingOverlay.hide();
  ToastHelper.showError("Operation failed");
}
```

### 5. InlineLoadingIndicator
Use for showing loading state within a widget.

**When to use:**
- Loading state for specific sections
- Non-blocking loading indicators
- List items or cards that are loading

**Usage:**
```dart
import 'package:aj_chat/widgets/loading_overlay.dart';

// Simple loading indicator
InlineLoadingIndicator()

// With message
InlineLoadingIndicator(
  message: "Loading messages...",
  size: 32,
)

// In a widget
if (isLoading)
  InlineLoadingIndicator(message: "Loading...")
else
  YourContent()
```

### 6. Inline Form Validation
Already implemented in ModernTextField component.

**Usage:**
```dart
import 'package:aj_chat/widgets/modern_text_field.dart';

ModernTextField(
  controller: _emailController,
  labelText: "Email",
  hintText: "Enter your email",
  prefixIcon: Icons.email_outlined,
  errorText: _emailError, // Shows error message with icon
  onChanged: (_) {
    // Clear error when user types
    if (_emailError != null) {
      setState(() {
        _emailError = null;
      });
    }
  },
)
```

## Best Practices

### 1. Choose the Right Component
- **ToastHelper**: Quick, non-critical messages (login success, logout)
- **SnackBarHelper**: Screen-specific feedback (message send failure, connection issues)
- **LoadingOverlay**: Blocking operations (file upload, registration)
- **InlineLoadingIndicator**: Section-specific loading (list loading, image loading)

### 2. Error Message Guidelines
- Be specific: "Failed to send message" instead of "Error occurred"
- Be helpful: "No user found with this email" instead of "Login failed"
- Be concise: Keep messages under 50 characters when possible
- Be consistent: Use similar wording for similar errors

### 3. Loading States
- Always hide loading overlays in finally blocks
- Show loading indicators for operations > 500ms
- Provide messages for operations > 2 seconds
- Never block UI for operations that can be async

### 4. Firebase Error Handling
```dart
try {
  await firebaseOperation();
  ToastHelper.showSuccess("Success message");
} on FirebaseAuthException catch (e) {
  String errorMessage = "Operation failed";
  if (e.code == 'user-not-found') {
    errorMessage = "No user found with this email";
  } else if (e.code == 'wrong-password') {
    errorMessage = "Incorrect password";
  } else if (e.code == 'invalid-email') {
    errorMessage = "Invalid email address";
  }
  ToastHelper.showError(errorMessage);
} catch (e) {
  ToastHelper.showError("An unexpected error occurred");
}
```

## Color Scheme

All feedback components use consistent colors from the theme:

- **Success**: Green (#10B981)
- **Error**: Red (#EF4444)
- **Warning**: Amber (#F59E0B)
- **Info**: Blue (#3B82F6)

## Accessibility

All components follow accessibility best practices:
- Sufficient color contrast (WCAG AA compliant)
- Appropriate text sizes (14-16sp)
- Clear icons for visual feedback
- Proper timing (3 seconds default for toasts)

## Migration from Old Code

### Before:
```dart
Fluttertoast.showToast(msg: "Login Successful");
```

### After:
```dart
ToastHelper.showSuccess("Login Successful");
```

### Before:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Failed to send message'),
    backgroundColor: Colors.red,
  ),
);
```

### After:
```dart
SnackBarHelper.showError(context, 'Failed to send message');
```

## Examples in Codebase

See these files for implementation examples:
- `lib/login.dart` - ToastHelper usage with Firebase errors
- `lib/sign_up_screen.dart` - ToastHelper with form validation
- `lib/chat.dart` - SnackBarHelper for screen-specific errors
- `lib/home.dart` - ToastHelper for logout functionality
- `lib/reset_password_screen.dart` - ToastHelper with Firebase errors
