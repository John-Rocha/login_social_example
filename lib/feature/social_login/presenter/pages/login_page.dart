import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:login_social_example/feature/social_login/presenter/cubit/auth_cubit.dart';
import 'package:login_social_example/feature/social_login/presenter/cubit/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Social'),
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 24,
              children: [
                const Icon(
                  Icons.login,
                  size: 64,
                  color: Colors.blue,
                ),
                const Text(
                  'Faça login para continuar',
                  style: TextStyle(fontSize: 18),
                ),
                ElevatedButton.icon(
                  onPressed: state is AuthLoading
                      ? null
                      : () {
                          context.read<AuthCubit>().signInWithGoogle();
                        },
                  icon: const Icon(Icons.login),
                  label: const Text('Login with Google'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
