import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/core/services/user_session_service.dart';
import 'package:flutter_application_1/core/auth/login_screen.dart';
import 'package:flutter_application_1/feature/presentation/pages/main_page.dart';

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Step 1: Initialize User Session
    await UserSessionService.instance.init();

    // Step 2: Artificial Delay for Animation (2 seconds)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Step 3: Check Authentication
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Not logged in -> Go to Login
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      // Logged in -> Ensure data is fresh -> Go to Home
      await UserSessionService.instance.refreshUser();
      
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MyHomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Lottie.asset(
          'assets/lottie/welcome_loading.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
