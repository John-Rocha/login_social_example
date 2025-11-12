import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_social_example/core/usecases/usecase.dart';
import 'package:login_social_example/feature/social_login/domain/usecases/get_current_user.dart';
import 'package:login_social_example/feature/social_login/domain/usecases/sign_in_with_google.dart';
import 'package:login_social_example/feature/social_login/domain/usecases/sign_out.dart';
import 'package:login_social_example/feature/social_login/presenter/cubit/auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignInWithGoogle signInWithGoogleUseCase;
  final SignOut signOutUseCase;
  final GetCurrentUser getCurrentUserUseCase;

  AuthCubit({
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthInitial()) {
    _checkCurrentUser();
  }

  Future<void> _checkCurrentUser() async {
    final result = await getCurrentUserUseCase(NoParams());

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) {
        if (user != null) {
          emit(AuthAuthenticated(user));
        } else {
          emit(const AuthUnauthenticated());
        }
      },
    );
  }

  Future<void> signInWithGoogle() async {
    emit(const AuthLoading());

    final result = await signInWithGoogleUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> signOut() async {
    emit(const AuthLoading());

    final result = await signOutUseCase(NoParams());

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
