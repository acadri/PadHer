import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticatedUser {
  const AuthenticatedUser({
    required this.uid,
    this.displayName,
    this.email,
  });

  final String uid;
  final String? displayName;
  final String? email;

  factory AuthenticatedUser.fromFirebase(User user) => AuthenticatedUser(
    uid: user.uid,
    displayName: user.displayName,
    email: user.email,
  );
}

abstract interface class AuthenticationService {
  AuthenticatedUser? get currentUser;
  Future<AuthenticatedUser> signInWithGoogle();
  Future<bool> hasTeacherAccess();
  Future<void> signOut();
}

class FirebaseAuthenticationService implements AuthenticationService {
  FirebaseAuthenticationService(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  @override
  AuthenticatedUser? get currentUser {
    final user = _firebaseAuth.currentUser;
    return user == null ? null : AuthenticatedUser.fromFirebase(user);
  }

  @override
  Future<AuthenticatedUser> signInWithGoogle() async {
    late final UserCredential credential;
    if (kIsWeb) {
      credential = await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
    } else {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      try {
        final googleUser = await googleSignIn.authenticate();
        final idToken = googleUser.authentication.idToken;
        if (idToken == null) {
          throw FirebaseAuthException(
            code: 'missing-google-id-token',
            message: 'Google sign-in did not return an ID token.',
          );
        }
        credential = await _firebaseAuth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: idToken),
        );
      } on GoogleSignInException catch (error) {
        if (error.code == GoogleSignInExceptionCode.canceled) {
          throw FirebaseAuthException(
            code: 'canceled',
            message: 'Google sign-in was canceled.',
          );
        }
        rethrow;
      }
    }
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'Google sign-in completed without returning a user.',
      );
    }
    return AuthenticatedUser.fromFirebase(user);
  }

  @override
  Future<bool> hasTeacherAccess() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return false;
    final claims = (await user.getIdTokenResult(true)).claims ?? const {};
    return claims['role'] == 'teacher' || claims['teacher'] == true;
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      await googleSignIn.signOut();
    }
  }
}