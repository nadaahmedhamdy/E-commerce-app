import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../Models/user_model.dart';
import '../services/auth_service.dart';
import '../Services/firestore_services.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AuthStatus status = AuthStatus.unknown;
  User? firebaseUser;
  AppUser? userProfile;
  bool isLoading = false;
  String? errorMessage;

  late final StreamSubscription<User?> _authSub;

  AuthProvider() {
    _authSub = _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    firebaseUser = user;
    if (user == null) {
      status = AuthStatus.unauthenticated;
      userProfile = null;
    } else {
      status = AuthStatus.authenticated;
      userProfile = await _firestoreService.getUserProfile(user.uid);
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) => _run(() async {
    await _authService.signInWithEmail(email, password);
  });

  Future<bool> signup(String name, String email, String password) =>
      _run(() async {
        await _authService.signUpWithEmail(name, email, password);
      });

  Future<bool> signInWithGoogle() => _run(() async {
    final user = await _authService.signInWithGoogle();
    if (user == null) {
      throw _SilentCancel();
    }
  });

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordReset(String email) =>
      _authService.sendPasswordResetEmail(email);

  Future<bool> _run(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      isLoading = false;
      notifyListeners();
      return true;
    } on _SilentCancel {
      isLoading = false;
      notifyListeners();
      return false;
    } on FirebaseAuthException catch (e) {
      isLoading = false;
      errorMessage = e.message ?? e.code;
      notifyListeners();
      return false;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _authSub.cancel();
    super.dispose();
  }
}

class _SilentCancel implements Exception {}
