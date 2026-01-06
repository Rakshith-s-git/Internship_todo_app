import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current firebase user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Register new user
  Future<String?> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw 'Please fill all fields';
      }

      if (!_isValidEmail(email)) {
        throw 'Please enter a valid email';
      }

      if (password.length < 6) {
        throw 'Password must be at least 6 characters long';
      }

      if (!_isStrongPassword(password)) {
        throw 'Password must contain uppercase, lowercase, and numbers';
      }

      // Create user account
      firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // Create user document in Firestore
      final user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email.trim(),
          'name': name.trim(),
          'createdAt': DateTime.now(),
        });
      }

      return null; // Success
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'Email already registered';
      } else if (e.code == 'weak-password') {
        return 'Password is too weak';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      }
      return e.message ?? 'Registration failed';
    } catch (e) {
      return e.toString();
    }
  }

  // Login user
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty) {
        throw 'Please fill all fields';
      }

      if (!_isValidEmail(email)) {
        throw 'Please enter a valid email';
      }

      // Sign in
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return null; // Success
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found with this email';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email address';
      } else if (e.code == 'user-disabled') {
        return 'User account has been disabled';
      }
      return e.message ?? 'Login failed';
    } catch (e) {
      return e.toString();
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get user details from Firestore
  Future<User?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      // Handle error silently
      return null;
    }
  }

  // Update user profile
  Future<String?> updateUserProfile({
    required String uid,
    required String name,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'name': name.trim(),
      });
      return null; // Success
    } catch (e) {
      return e.toString();
    }
  }

  // Helper: Validate email format
  bool _isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Helper: Check password strength
  bool _isStrongPassword(String password) {
    final RegExp hasUppercase = RegExp(r'[A-Z]');
    final RegExp hasLowercase = RegExp(r'[a-z]');
    final RegExp hasNumber = RegExp(r'[0-9]');

    return hasUppercase.hasMatch(password) &&
        hasLowercase.hasMatch(password) &&
        hasNumber.hasMatch(password);
  }
}
