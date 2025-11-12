import 'package:dartz/dartz.dart';
import 'package:login_social_example/core/errors/failures.dart';
import 'package:login_social_example/feature/social_login/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithGoogle();
  Future<Either<Failure, void>> signOut();
  Either<Failure, UserEntity?> getCurrentUser();
}
