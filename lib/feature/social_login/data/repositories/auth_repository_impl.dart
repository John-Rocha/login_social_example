import 'package:dartz/dartz.dart';
import 'package:login_social_example/core/errors/exceptions.dart';
import 'package:login_social_example/core/errors/failures.dart';
import 'package:login_social_example/feature/social_login/data/datasources/auth_remote_datasource.dart';
import 'package:login_social_example/feature/social_login/domain/entities/user_entity.dart';
import 'package:login_social_example/feature/social_login/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final userModel = await _remoteDataSource.signInWithGoogle();
      if (userModel == null) {
        return const Left(CancelledByUserFailure());
      }
      return Right(userModel.toEntity());
    } on CancelledByUserException {
      return const Left(CancelledByUserFailure());
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Either<Failure, UserEntity?> getCurrentUser() {
    try {
      final userModel = _remoteDataSource.getCurrentUser();
      return Right(userModel?.toEntity());
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
