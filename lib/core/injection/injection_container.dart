import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_social_example/feature/social_login/data/repositories/auth_repository_impl.dart';
import 'package:login_social_example/feature/social_login/data/services/facebook_sign_in_service.dart';
import 'package:login_social_example/feature/social_login/data/services/google_sign_in_service.dart';
import 'package:login_social_example/feature/social_login/domain/repositories/auth_repository.dart';
import 'package:login_social_example/feature/social_login/presenter/cubit/auth_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Cubit
  sl.registerFactory(
    () => AuthCubit(
      authRepository: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      googleSignInService: sl(),
      facebookSignInService: sl(),
      firebaseAuth: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton<GoogleSignInService>(
    () => GoogleSignInServiceImpl(
      firebaseAuth: sl(),
      googleSignIn: sl(),
    ),
  );

  sl.registerLazySingleton<FacebookSignInService>(
    () => FacebookSignInServiceImpl(
      firebaseAuth: sl(),
      facebookAuth: sl(),
    ),
  );

  // External
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => GoogleSignIn.instance);
  sl.registerLazySingleton(() => FacebookAuth.instance);
}
