import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  String? get currentUid => _auth.currentUser?.uid;

  Future<UserCredential> signInAnonymously() async {
    if (_auth.currentUser != null) {
      return UserCredentialPlatformBridge.currentUserCredential(_auth.currentUser!);
    }

    return _auth.signInAnonymously();
  }
}

class UserCredentialPlatformBridge implements UserCredential {
  UserCredentialPlatformBridge._(this.user);

  @override
  final User? user;

  static UserCredential currentUserCredential(User user) {
    return UserCredentialPlatformBridge._(user);
  }

  @override
  AdditionalUserInfo? get additionalUserInfo => null;

  @override
  AuthCredential? get credential => null;
}