import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

abstract class FacebookSignInService {
  Future<UserCredential> signInWithFacebook();
  Future<void> signOut();
}

class FacebookSignInServiceImpl implements FacebookSignInService {
  final FirebaseAuth _firebaseAuth;
  final FacebookAuth _facebookAuth;

  FacebookSignInServiceImpl({
    required FirebaseAuth firebaseAuth,
    required FacebookAuth facebookAuth,
  }) : _firebaseAuth = firebaseAuth,
       _facebookAuth = facebookAuth;

  @override
  Future<UserCredential> signInWithFacebook() async {
    final LoginResult result = await _facebookAuth.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.success) {
      // Criar credencial a partir do access token
      final OAuthCredential credential = FacebookAuthProvider.credential(
        result.accessToken!.tokenString,
      );

      // Uma vez autenticado, retornar o UserCredential
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      return userCredential;
    } else if (result.status == LoginStatus.cancelled) {
      throw Exception('Login cancelado pelo usuário');
    } else {
      throw Exception('Falha no login: ${result.message}');
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_firebaseAuth.signOut(), _facebookAuth.logOut()]);
  }
}
