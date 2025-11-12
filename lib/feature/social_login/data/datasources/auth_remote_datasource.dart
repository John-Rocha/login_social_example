import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_social_example/feature/social_login/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel?> signInWithGoogle();
  Future<void> signOut();
  UserModel? getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _googleSignIn = GoogleSignIn.instance;

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      // Inicializar o GoogleSignIn com o serverClientId
      await _googleSignIn.initialize(
        serverClientId: '367781060028-ucft3oj5uhflgcmnu8k9s337f42j7pvm.apps.googleusercontent.com',
      );

      // Autenticar o usuário
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      if (userCredential.user == null) {
        return null;
      }

      return UserModel.fromFirebaseUser(userCredential.user!);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.disconnect(),
    ]);
  }

  @override
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    return user != null ? UserModel.fromFirebaseUser(user) : null;
  }
}
