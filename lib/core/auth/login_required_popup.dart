import 'package:flutter/material.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';
import 'package:flutter_application_1/core/auth/login_screen.dart';

class LoginRequiredPopup extends StatelessWidget {
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const LoginRequiredPopup({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(loc.loginRequired),
      content: Text(loc.loginRequiredMessage),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: Text(loc.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(context); // Close popup
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
            if (result == true) {
              onConfirm();
            }
          },
          child: Text(loc.login),
        ),
      ],
    );
  }
}

void showLoginRequiredPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => LoginRequiredPopup(
      onConfirm: () {
        // Navigation is now handled inside the popup
      },
      onCancel: () {
        Navigator.pop(context);
      },
    ),
  );
}
