import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_social_example/feature/social_login/data/datasources/auth_remote_datasource.dart';
import 'package:login_social_example/feature/social_login/data/repositories/auth_repository_impl.dart';
import 'package:login_social_example/feature/social_login/domain/repositories/auth_repository.dart';
import 'package:login_social_example/feature/social_login/domain/usecases/get_current_user.dart';
import 'package:login_social_example/feature/social_login/domain/usecases/sign_in_with_google.dart';
import 'package:login_social_example/feature/social_login/domain/usecases/sign_out.dart';
import 'package:login_social_example/feature/social_login/presenter/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      signInWithGoogleUseCase: sl(),
      signOutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => SignInWithGoogle(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);
}
