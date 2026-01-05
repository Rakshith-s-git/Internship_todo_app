import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../models/user_model.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current firebase user
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Register a new user
  Future<String?> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Validate inputs
      if (email.isEmpty || password.isEmpty || username.isEmpty) {
        throw 'All fields are required.';
      }

      if (!_isValidEmail(email)) {
        throw 'Invalid email format.';
      }

      if (password.length < 6) {
        throw 'Password must be at least 6 characters long.';
      }

      // Create user account
      final firebase_auth.UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // Store additional user information in Firestore
      final user = userCredential.user;
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'username': username,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null; // Return null if registration is successful
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return 'The email address is already in use by another account.';
      } else if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      }
      return e.message ?? 'Registration failed. Please try again.';
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
        throw 'Email and password are required.';
      }

      if (!_isValidEmail(email)) {
        throw 'Invalid email format.';
      }

      // Sign in user
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // Return null if login is successful
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else if (e.code == 'user-disabled') {
        return 'This user account has been disabled.';
      }
      return e.message ?? 'Login failed. Please try again.';
    } catch (e) {
      return e.toString();
    }
  }

  // Logout user
  Future<void> logout() async {
    await _auth.signOut();
  }

  // Get User details from Firestore
  Future<User?> getUserDetails(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
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
  // bool _isStrongPassword(String password) {
  //   final RegExp hasUppercase = RegExp(r'[A-Z]');
  //   final RegExp hasLowercase = RegExp(r'[a-z]');
  //   final RegExp hasNumber = RegExp(r'[0-9]');

  //   return hasUppercase.hasMatch(password) &&
  //       hasLowercase.hasMatch(password) &&
  //       hasNumber.hasMatch(password);
  // }
}
