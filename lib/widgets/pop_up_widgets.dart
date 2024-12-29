import 'dart:ui';
import 'package:flutter/material.dart';

class PopUpWidgets {
// Show Top Snackbar
  static void showBlurredSnackBar(
    BuildContext context,
    String message, {
    bool isSuccess = true,
  }) {
    final overlay = Overlay.of(context); // Access the overlay

    // Create OverlayEntry
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // Distance from the top
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent, // Transparent Material
          child: AnimatedOpacity(
            opacity: 1.0,
            duration: const Duration(milliseconds: 500), // Animation Duration
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Blur Effect
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSuccess
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2), // Transparent Colors
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSuccess ? Colors.greenAccent : Colors.redAccent,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSuccess ? Icons.check_circle : Icons.error,
                        color: isSuccess
                            ? Colors.greenAccent
                            : Colors.redAccent, // Icon Colors
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          message,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Insert Overlay Entry
    overlay.insert(overlayEntry);

    // Remove after delay
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove(); // Remove after 3 seconds
    });
  }
}
