import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:login_social_example/core/injection/injection_container.dart';
import 'package:login_social_example/feature/social_login/presenter/cubit/auth_cubit.dart';
import 'package:login_social_example/feature/social_login/presenter/cubit/auth_state.dart';
import 'package:login_social_example/feature/social_login/presenter/pages/home_page.dart';
import 'package:login_social_example/feature/social_login/presenter/pages/login_page.dart';

class AppRouter {
  static final authCubit = sl<AuthCubit>();

  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final authState = authCubit.state;
      final isLoginRoute = state.matchedLocation == '/login';

      // Se está autenticado e tentando acessar o login, redireciona para home
      if (authState is AuthAuthenticated && isLoginRoute) {
        return '/home';
      }

      // Se não está autenticado e não está no login, redireciona para login
      if (authState is! AuthAuthenticated && !isLoginRoute) {
        return '/login';
      }

      // Caso contrário, permite acesso à rota
      return null;
    },
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => BlocProvider.value(
          value: authCubit,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => BlocProvider.value(
          value: authCubit,
          child: const HomePage(),
        ),
      ),
    ],
  );
}

// Helper class para fazer o GoRouter reagir ao stream do Cubit
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
