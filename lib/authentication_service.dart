import 'package:firebase_auth/firebase_auth.dart';

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
  Future<AuthenticatedUser> signInWithGitHub();
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
  Future<AuthenticatedUser> signInWithGitHub() async {
    final provider = OAuthProvider('github.com')..addScope('read:user');
    final credential = await _firebaseAuth.signInWithProvider(provider);
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'missing-user',
        message: 'GitHub sign-in completed without returning a user.',
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
  Future<void> signOut() => _firebaseAuth.signOut();
}