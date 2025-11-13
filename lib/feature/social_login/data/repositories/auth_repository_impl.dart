import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_social_example/core/errors/exceptions.dart';
import 'package:login_social_example/core/errors/failures.dart';
import 'package:login_social_example/feature/social_login/data/models/user_model.dart';
import 'package:login_social_example/feature/social_login/data/services/google_sign_in_service.dart';
import 'package:login_social_example/feature/social_login/data/services/facebook_sign_in_service.dart';
import 'package:login_social_example/feature/social_login/domain/entities/user_entity.dart';
import 'package:login_social_example/feature/social_login/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignInService _googleSignInService;
  final FacebookSignInService _facebookSignInService;
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({
    required GoogleSignInService googleSignInService,
    required FacebookSignInService facebookSignInService,
    required FirebaseAuth firebaseAuth,
  }) : _googleSignInService = googleSignInService,
       _facebookSignInService = facebookSignInService,
       _firebaseAuth = firebaseAuth;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userCredential = await _googleSignInService.signInWithGoogle();

      if (userCredential.user == null) {
        return const Left(AuthFailure('Falha ao fazer login'));
      }

      final userModel = UserModel.fromFirebaseUser(userCredential.user!);
      return Right(userModel.toEntity());
    } on CancelledByUserException {
      return const Left(CancelledByUserFailure());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Erro ao autenticar'));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithFacebook() async {
    try {
      final userCredential = await _facebookSignInService.signInWithFacebook();

      if (userCredential.user == null) {
        return const Left(AuthFailure('Falha ao fazer login'));
      }

      // Busca os dados do usuário do Facebook para obter a foto em alta resolução
      String? facebookPhotoUrl;
      try {
        final facebookData = await _facebookSignInService.getUserData();
        // A foto está em: facebookData['picture']['data']['url']
        if (facebookData['picture'] != null &&
            facebookData['picture']['data'] != null) {
          facebookPhotoUrl = facebookData['picture']['data']['url'];
        }
      } catch (e) {
        // Se falhar ao buscar a foto do Facebook, usa a foto do Firebase
        print('Erro ao buscar foto do Facebook: $e');
      }

      final userModel = UserModel.fromFirebaseUser(
        userCredential.user!,
        facebookPhotoUrl: facebookPhotoUrl,
      );
      return Right(userModel.toEntity());
    } on CancelledByUserException {
      return const Left(CancelledByUserFailure());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Erro ao autenticar'));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _googleSignInService.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on FirebaseAuthException catch (e) {
      return Left(AuthFailure(e.message ?? 'Erro ao fazer logout'));
    } catch (e) {
      return Left(AuthFailure('Erro inesperado: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, UserEntity?>> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Right(null);
      }

      // Verifica se o usuário está logado com Facebook para buscar a foto em alta resolução
      String? facebookPhotoUrl;
      final isFacebookUser = user.providerData.any(
        (provider) => provider.providerId == 'facebook.com',
      );

      if (isFacebookUser) {
        try {
          final facebookData = await _facebookSignInService.getUserData();
          if (facebookData['picture'] != null &&
              facebookData['picture']['data'] != null) {
            facebookPhotoUrl = facebookData['picture']['data']['url'];
          }
        } catch (e) {
          // Se falhar ao buscar a foto do Facebook, usa a foto do Firebase
          print('Erro ao buscar foto do Facebook: $e');
        }
      }

      final userModel = UserModel.fromFirebaseUser(
        user,
        facebookPhotoUrl: facebookPhotoUrl,
      );
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure('Erro ao obter usuário: ${e.toString()}'));
    }
  }
}
