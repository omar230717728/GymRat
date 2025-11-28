import 'package:firebase_auth/firebase_auth.dart';

bool isUserLoggedIn() {
  return FirebaseAuth.instance.currentUser != null;
}
