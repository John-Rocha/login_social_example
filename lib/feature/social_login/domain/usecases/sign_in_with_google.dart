import 'package:dartz/dartz.dart';
import 'package:login_social_example/core/errors/failures.dart';
import 'package:login_social_example/core/usecases/usecase.dart';
import 'package:login_social_example/feature/social_login/domain/entities/user_entity.dart';
import 'package:login_social_example/feature/social_login/domain/repositories/auth_repository.dart';

class SignInWithGoogle implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  SignInWithGoogle(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.signInWithGoogle();
  }
}
