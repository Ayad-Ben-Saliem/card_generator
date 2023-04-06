import 'package:card_generator/services/auth_service.dart';
import 'package:card_generator/static.dart';
import 'package:card_generator/ui/app.dart';
import 'package:card_generator/ui/auth/reset_password_page.dart';
import 'package:card_generator/ui/custom-text-field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emailProvider = StateProvider((ref) => '');
final _password = StateProvider((ref) => '');
final _errorMessage = StateProvider((ref) => '');

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return FlutterLogin(
    //   title: 'Title ...',
    //   logo: null,
    //   messages: LoginMessages(
    //     userHint: 'Email',
    //     passwordHint: 'password',
    //     forgotPasswordButton: 'Forgot Password',
    //     loginButton: 'Login',
    //     // recoverPasswordDescription: 'recoverPasswordDescription',
    //     // recoverPasswordIntro: 'recoverPasswordIntro',
    //     recoverPasswordSuccess: 'recoverPasswordSuccess',
    //   ),
    //   onLogin: (data) async => '',
    //   onRecoverPassword: (_) async => null,
    // );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 256),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  return CustomTextField(
                    text: ref.watch(emailProvider),
                    decoration: const InputDecoration(labelText: 'Email'),
                    onChanged: (txt) =>
                        ref.read(emailProvider.notifier).state = txt,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, _) {
                  return CustomTextField(
                    text: ref.watch(_password),
                    passwordField: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    onChanged: (txt) =>
                        ref.read(_password.notifier).state = txt,
                  );
                },
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  return ElevatedButton(
                    onPressed: () => login(context, ref),
                    child: const Text('Login'),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ResetPasswordPage(),
                    ),
                  );
                },
                child: const Text('Forget password'),
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  return Text(
                    ref.watch(_errorMessage),
                    style: errorTextStyle(context),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void login(BuildContext context, WidgetRef ref) {
    final email = ref.read(emailProvider);
    final password = ref.read(_password);
    AuthService.login(email, password).then((user) {
      if (user == null) {
        ref.read(_errorMessage.notifier).state =
            'Either email or password incorrect!!!';
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed')),
        );
      } else {
        ref.read(_errorMessage.notifier).state = '';
        ref.read(authenticatedUser.notifier).state = user;
      }
    });
  }
}
