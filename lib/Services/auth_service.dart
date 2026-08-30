import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return credential.user;
  }

  Future<User?> signUpWithEmail(
      String name,
      String email,
      String password,
      ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await user.updateDisplayName(name);
      await _createUserDocIfMissing(
        uid: user.uid,
        name: name,
        email: email.trim(),
        photoUrl: '',
      );
    }
    return user;
  }

  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      return null;
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user;
    if (user != null) {
      await _createUserDocIfMissing(
        uid: user.uid,
        name: user.displayName ?? googleUser.displayName ?? 'User',
        email: user.email ?? googleUser.email,
        photoUrl: user.photoURL ?? googleUser.photoUrl ?? '',
      );
    }
    return user;
  }

  Future<void> _createUserDocIfMissing({
    required String uid,
    required String name,
    required String email,
    required String photoUrl,
  }) async {
    final docRef = _firestore.collection('users').doc(uid);
    final doc = await docRef.get();
    if (!doc.exists) {
      final appUser = AppUser(
        uid: uid,
        name: name,
        email: email,
        photoUrl: photoUrl,
      );
      await docRef.set(appUser.toMap());
    }
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
