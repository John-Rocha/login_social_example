import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login_social_example/core/errors/exceptions.dart';
import 'package:login_social_example/core/errors/failures.dart';
import 'package:login_social_example/feature/social_login/data/models/user_model.dart';
import 'package:login_social_example/feature/social_login/data/services/google_sign_in_service.dart';
import 'package:login_social_example/feature/social_login/domain/entities/user_entity.dart';
import 'package:login_social_example/feature/social_login/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final GoogleSignInService _googleSignInService;
  final FirebaseAuth _firebaseAuth;

  AuthRepositoryImpl({
    required GoogleSignInService googleSignInService,
    required FirebaseAuth firebaseAuth,
  })  : _googleSignInService = googleSignInService,
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
  Either<Failure, UserEntity?> getCurrentUser() {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return const Right(null);
      }

      final userModel = UserModel.fromFirebaseUser(user);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(AuthFailure('Erro ao obter usuário: ${e.toString()}'));
    }
  }
}
