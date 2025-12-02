import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_1/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Form keys
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  final _signupFullNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();

  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupFullNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      await cred.user?.reload();
      final user = _auth.currentUser;

      if (user != null && !user.emailVerified) {
        _showSnack(AppLocalizations.of(context)!.verifyEmailMessage);
        setState(() => _isLoading = false);
        return;
      }

      _onAuthSuccess();
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? AppLocalizations.of(context)!.loginFailed);
    } catch (e) {
      _showSnack('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSignup() async {
    if (!_signupFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final email = _signupEmailController.text.trim();
      final password = _signupPasswordController.text;
      final fullName = _signupFullNameController.text.trim();

      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;
      if (user == null) {
        _showSnack(AppLocalizations.of(context)!.signupFailed);
        setState(() => _isLoading = false);
        return;
      }

      await user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set({
        'name': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'favoritesCount': 0,
      });

      _onAuthSuccess();
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? AppLocalizations.of(context)!.signupFailed);
    } catch (e) {
      _showSnack('Something went wrong: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final controller = TextEditingController(text: _loginEmailController.text);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.resetPassword),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = controller.text.trim();
                if (email.isEmpty) return;

                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  _showSnack(AppLocalizations.of(context)!.passwordResetSent);
                } on FirebaseAuthException catch (e) {
                  _showSnack(e.message ?? AppLocalizations.of(context)!.failedToSendReset);
                }
              },
              child: Text(AppLocalizations.of(context)!.send),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;

      if (user == null) {
        _showSnack('Google sign-in failed.');
        setState(() => _isLoading = false);
        return;
      }

      final userRef = _firestore.collection('users').doc(user.uid);
      if (!(await userRef.get()).exists) {
        await userRef.set({
          'name': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
          'favoritesCount': 0,
        });
      }

      _onAuthSuccess();
    } catch (e) {
      _showSnack('Google sign-in failed: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onAuthSuccess() {
    // Go back to previous screen or replace with your home page route
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.85),
              theme.colorScheme.secondary.withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedScale(
                  scale: 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),
                          Hero(
                            tag: 'gymrat-logo',
                            child: Icon(
                              Icons.fitness_center,
                              size: 56,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'GymRat',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            AppLocalizations.of(context)!.welcomeBackBeast,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),

                          // Tabs: Login / Sign up
                          TabBar(
                            controller: _tabController,
                            labelColor: theme.colorScheme.primary,
                            unselectedLabelColor:
                                theme.textTheme.bodyMedium?.color,
                            indicatorColor: theme.colorScheme.primary,
                            tabs: [
                              Tab(text: AppLocalizations.of(context)!.login),
                              Tab(text: AppLocalizations.of(context)!.signup),
                            ],
                            onTap: (index) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 12),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: _tabController.index == 0
                                ? _buildLoginForm(context)
                                : _buildSignupForm(context),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
              prefixIcon: const Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.emailRequired;
              }
              if (!value.contains('@')) {
                return AppLocalizations.of(context)!.validEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _loginPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
              prefixIcon: const Icon(Icons.lock),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.passwordRequired;
              }
              if (value.length < 6) {
                return AppLocalizations.of(context)!.minCharacters;
              }
              return null;
            },
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _isLoading ? null : _handleForgotPassword,
              child: Text(AppLocalizations.of(context)!.forgotPassword),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Text(AppLocalizations.of(context)!.login),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(AppLocalizations.of(context)!.or),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _handleGoogleSignIn,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: Text(AppLocalizations.of(context)!.googleSignIn),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _signupFullNameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.fullName,
              prefixIcon: const Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.nameRequired;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signupEmailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.email,
              prefixIcon: const Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return AppLocalizations.of(context)!.emailRequired;
              }
              if (!value.contains('@')) {
                return AppLocalizations.of(context)!.validEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signupPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.password,
              prefixIcon: const Icon(Icons.lock),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppLocalizations.of(context)!.passwordRequired;
              }
              if (value.length < 6) {
                return AppLocalizations.of(context)!.minCharacters;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignup,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.createAccount),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.verificationNote,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
