import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_application_1/feature/presentation/pages/main_page.dart';

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

  // -----------------------------------------
  // LOGIN
  // -----------------------------------------
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
        _showSnack('Please verify your email before logging in.');
        setState(() => _isLoading = false);
        return;
      }

      _onAuthSuccess();
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Login failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -----------------------------------------
  // SIGNUP
  // -----------------------------------------
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
        _showSnack('Signup failed.');
        setState(() => _isLoading = false);
        return;
      }

      await user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set({
        'name': fullName,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'favoritesCount': 0,
        'theme': 'green',
      });

      _showSnack('Account created! Please verify your email.');

      _tabController.animateTo(0);
    } on FirebaseAuthException catch (e) {
      _showSnack(e.message ?? 'Signup failed');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -----------------------------------------
  // FORGOT PASSWORD
  // -----------------------------------------
  Future<void> _handleForgotPassword() async {
    final controller = TextEditingController(text: _loginEmailController.text);

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Reset Password'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Email',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = controller.text.trim();
                if (email.isEmpty) return;

                try {
                  await _auth.sendPasswordResetEmail(email: email);
                  Navigator.pop(context);
                  _showSnack('Password reset email sent.');
                } catch (e) {
                  _showSnack('Error sending reset email.');
                }
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  // -----------------------------------------
  // GOOGLE SIGN-IN
  // -----------------------------------------
  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final googleUser = await googleSignIn.signIn();
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
        _showSnack('Google login failed.');
        setState(() => _isLoading = false);
        return;
      }

      final userRef = _firestore.collection('users').doc(user.uid);
      
      // Always update user data to ensure we have the latest name/photo
      await userRef.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL,
        'lastLogin': FieldValue.serverTimestamp(),
        // Only set createdAt if it doesn't exist (using merge)
        // Note: set with merge will overwrite fields present in the map. 
        // To preserve createdAt if it exists, we shouldn't overwrite it if we can help it, 
        // but with set(merge) we can't conditionally set.
        // Better approach: update specific fields.
      }, SetOptions(merge: true));

      // Ensure createdAt exists
      final docSnap = await userRef.get();
      if (!docSnap.exists || !docSnap.data()!.containsKey('createdAt')) {
         await userRef.set({'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      }
      
      // Initialize other fields if missing
      if (!docSnap.exists || !docSnap.data()!.containsKey('favoritesCount')) {
         await userRef.set({'favoritesCount': 0, 'theme': 'green'}, SetOptions(merge: true));
      }

      _onAuthSuccess();
    } catch (e) {
      _showSnack('Google sign-in failed.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // -----------------------------------------
  // SUCCESS → Pop with TRUE
  // -----------------------------------------
  void _onAuthSuccess() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MyHomePage()),
      (route) => false,
    );
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  elevation: 10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          color: theme.colorScheme.primary,
                          size: 58,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "GymRat",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Tabs
                        TabBar(
                          controller: _tabController,
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor:
                              theme.textTheme.bodyMedium?.color,
                          indicatorColor: theme.colorScheme.primary,
                          tabs: const [
                            Tab(text: "Login"),
                            Tab(text: "Sign Up"),
                          ],
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          height: 320,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              _buildLoginForm(context),
                              _buildSignupForm(context),
                            ],
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
      ),
    );
  }

  // -----------------------------------------
  // LOGIN FORM
  // -----------------------------------------
  Widget _buildLoginForm(BuildContext context) {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _loginEmailController,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (v) =>
                v == null || !v.contains('@') ? "Enter valid email" : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _loginPasswordController,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (v) =>
                v == null || v.length < 6 ? "Min 6 characters" : null,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _handleForgotPassword,
              child: const Text("Forgot Password?"),
            ),
          ),
          const SizedBox(height: 10),

          // LOGIN BUTTON
          ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text("Login"),
          ),

          const SizedBox(height: 14),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text("OR"),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 14),

          OutlinedButton.icon(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            icon: const Icon(Icons.g_mobiledata, size: 28),
            label: const Text("Continue with Google"),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------
  // SIGNUP FORM
  // -----------------------------------------
  Widget _buildSignupForm(BuildContext context) {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          TextFormField(
            controller: _signupFullNameController,
            decoration: const InputDecoration(labelText: "Full Name"),
            validator: (v) =>
                v == null || v.trim().isEmpty ? "Full name required" : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signupEmailController,
            decoration: const InputDecoration(labelText: "Email"),
            validator: (v) =>
                v == null || !v.contains('@') ? "Enter valid email" : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _signupPasswordController,
            decoration: const InputDecoration(labelText: "Password"),
            obscureText: true,
            validator: (v) =>
                v == null || v.length < 6 ? "Min 6 characters" : null,
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: _isLoading ? null : _handleSignup,
            child: _isLoading
                ? const CircularProgressIndicator()
                : const Text("Create Account"),
          ),
        ],
      ),
    );
  }
}
