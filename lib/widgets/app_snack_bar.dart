import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final colors = _getColors(type);
    final icon = _getIcon(type);
    final bgColors = _getBgColors(type);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: colors, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        backgroundColor: bgColors,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          // side: BorderSide(color: colors, width: 1),
        ),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: duration,
        action:
            actionLabel != null
                ? SnackBarAction(
                  label: actionLabel,
                  textColor: colors,
                  onPressed: onActionPressed ?? () {},
                )
                : null,
        elevation: 2,
      ),
    );
  }

  static Color _getColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const Color(0xFF4CAF50);
      case SnackBarType.error:
        return const Color(0xFFF44336);
      case SnackBarType.warning:
        return const Color(0xFFFF9800);
      case SnackBarType.info:
        return const Color(0xFF2196F3);
    }
  }

  static Color _getBgColors(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Colors.green.shade100;
      case SnackBarType.error:
        return Colors.red.shade100;
      case SnackBarType.warning:
        return Colors.orange.shade100;
      case SnackBarType.info:
        return Colors.blue.shade100;
    }
  }

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_rounded;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }
}

// Usage Examples:
// 
// Basic usage:
// AppSnackBar.show(context, message: "Updating profile...");
//
// Success message:
// AppSnackBar.show(
//   context,
//   message: "Profile updated successfully!",
//   type: SnackBarType.success,
// );
//
// Error message:
// AppSnackBar.show(
//   context,
//   message: "Failed to update profile",
//   type: SnackBarType.error,
// );
//
// Warning message:
// AppSnackBar.show(
//   context,
//   message: "Please check your internet connection",
//   type: SnackBarType.warning,
// );
//
// With action button:
// AppSnackBar.show(
//   context,
//   message: "Profile updated successfully!",
//   type: SnackBarType.success,
//   actionLabel: "VIEW",
//   onActionPressed: () {
//     // Navigate to profile or perform action
//   },
// );
//
// Custom duration:
// AppSnackBar.show(
//   context,
//   message: "This will stay for 5 seconds",
//   duration: const Duration(seconds: 5),
// );