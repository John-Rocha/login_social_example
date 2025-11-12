import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class GoogleSignInService {
  Future<UserCredential> signInWithGoogle();
  Future<void> signOut();
}

class GoogleSignInServiceImpl implements GoogleSignInService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  GoogleSignInServiceImpl({
    required FirebaseAuth firebaseAuth,
    required GoogleSignIn googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Future<UserCredential> signInWithGoogle() async {
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

    return userCredential;
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.disconnect(),
    ]);
  }
}
