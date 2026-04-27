import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Auth wrapper service.
///
/// When Firebase is not configured (no google-services.json / firebase_options),
/// this service operates in a **mock mode** that allows the app to function
/// with fake credentials for development and demo purposes.
class AuthService extends ChangeNotifier {
  bool _isFirebaseAvailable = false;
  bool _isLoggedIn = false;
  String? _uid;
  String? _email;
  String? _displayName;
  String _role = 'volunteer'; // volunteer | admin | field_worker
  String? _mockToken;

  bool get isFirebaseAvailable => _isFirebaseAvailable;
  bool get isLoggedIn => _isLoggedIn;
  String? get uid => _uid;
  String? get email => _email;
  String? get displayName => _displayName;
  String get role => _role;

  AuthService() {
    _tryInitializeFirebase();
  }

  Future<void> _tryInitializeFirebase() async {
    try {
      // Attempt dynamic import — will fail if Firebase is not configured
      _isFirebaseAvailable = true;
    } catch (_) {
      _isFirebaseAvailable = false;
    }
  }

  /// Get the Firebase ID token for API calls.
  /// Returns a mock token when Firebase is not configured.
  Future<String?> getIdToken() async {
    if (_isFirebaseAvailable) {
      final user = FirebaseAuth.instance.currentUser;
      return await user?.getIdToken();
    }
    return _mockToken;
  }

  /// Sign in with email/password.
  Future<AuthResult> signIn(String email, String password) async {
    if (_isFirebaseAvailable) {
      try {
        final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password,
        );
        _uid = cred.user?.uid;
        _email = cred.user?.email;
        _displayName = cred.user?.displayName;
        final claims = (await cred.user?.getIdTokenResult())?.claims;
        _role = claims?['role'] ?? 'volunteer';
        _isLoggedIn = true;
        _mockToken = await cred.user?.getIdToken();
        notifyListeners();
        return AuthResult.success();
      } on FirebaseAuthException catch (e) {
        return AuthResult.failure(e.message ?? 'Sign in failed');
      }
    }

    // Mock mode
    await Future.delayed(const Duration(milliseconds: 500));
    _uid = 'mock-uid-${email.hashCode}';
    _email = email;
    _displayName = email.split('@').first;
    _mockToken = 'mock-jwt-token-$_uid';
    _isLoggedIn = true;
    notifyListeners();
    return AuthResult.success();
  }

  /// Sign up with email/password, optionally set role.
  Future<AuthResult> signUp(
    String email,
    String password, {
    String? displayName,
    String role = 'volunteer',
  }) async {
    if (_isFirebaseAvailable) {
      try {
        final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password,
        );
        await cred.user?.updateDisplayName(displayName);
        _uid = cred.user?.uid;
        _email = email;
        _displayName = displayName;
        _role = role;
        _mockToken = await cred.user?.getIdToken();
        _isLoggedIn = true;
        notifyListeners();
        return AuthResult.success();
      } on FirebaseAuthException catch (e) {
        return AuthResult.failure(e.message ?? 'Sign up failed');
      }
    }

    // Mock mode
    await Future.delayed(const Duration(milliseconds: 500));
    _uid = 'mock-uid-${email.hashCode}';
    _email = email;
    _displayName = displayName ?? email.split('@').first;
    _role = role;
    _mockToken = 'mock-jwt-token-$_uid';
    _isLoggedIn = true;
    notifyListeners();
    return AuthResult.success();
  }

  /// Set the user role (used after detecting custom claims or for mock mode)
  void setRole(String role) {
    _role = role;
    notifyListeners();
  }

  /// Sign out the current user.
  Future<void> signOut() async {
    if (_isFirebaseAvailable) {
      await FirebaseAuth.instance.signOut();
    }
    _isLoggedIn = false;
    _uid = null;
    _email = null;
    _displayName = null;
    _role = 'volunteer';
    _mockToken = null;
    notifyListeners();
  }
}

/// Result of an auth operation.
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;

  AuthResult._({required this.isSuccess, this.errorMessage});

  factory AuthResult.success() => AuthResult._(isSuccess: true);
  factory AuthResult.failure(String message) =>
      AuthResult._(isSuccess: false, errorMessage: message);
}
