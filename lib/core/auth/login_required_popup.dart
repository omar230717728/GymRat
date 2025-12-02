import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/auth/login_screen.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class LoginRequiredPopup extends StatelessWidget {
  final VoidCallback onConfirm;   // Login / Signup
  final VoidCallback onCancel;    // Close popup

  const LoginRequiredPopup({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🔹 Background blur + tap to dismiss
        GestureDetector(
          onTap: onCancel,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),

        // 🔹 Center animated popup card
        Center(
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutBack,
            tween: Tween<double>(begin: 0.85, end: 1.0),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 1.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withOpacity(0.2),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Text(
                    AppLocalizations.of(context)!.signInToSaveFavorites,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color:
                          Theme.of(context).colorScheme.onSurface,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Subtitle
                  Text(
                    AppLocalizations.of(context)!.createAccountToSave,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Confirm button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.loginCreateAccount,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Cancel button
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      AppLocalizations.of(context)!.cancel,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.7),
                        fontSize: 15,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
void showLoginRequiredPopup(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return LoginRequiredPopup(
        onConfirm: () {
          Navigator.pop(context);

          // Navigate to login screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        onCancel: () {
          Navigator.pop(context);
        },
      );
    },
  );
}

