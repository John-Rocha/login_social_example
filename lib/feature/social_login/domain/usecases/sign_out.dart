import 'package:dartz/dartz.dart';
import 'package:login_social_example/core/errors/failures.dart';
import 'package:login_social_example/core/usecases/usecase.dart';
import 'package:login_social_example/feature/social_login/domain/repositories/auth_repository.dart';

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}
