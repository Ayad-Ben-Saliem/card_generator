import 'package:card_generator/services/auth_service.dart';
import 'package:card_generator/static.dart';
import 'package:card_generator/ui/auth/login_page.dart';
import 'package:card_generator/ui/custom-text-field.dart';
import 'package:card_generator/ui/disable-widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final _otp = StateProvider((ref) => '');
final _otpSent = StateProvider((ref) => false);
final _errorMessage = StateProvider((ref) => '');

class ResetPasswordPage extends ConsumerWidget {
  const ResetPasswordPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password Page'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 256),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Description ...'),
              const SizedBox(height: 64),
              Consumer(
                builder: (context, ref, child) {
                  return CustomTextField(
                    text: ref.watch(emailProvider),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      suffix: TextButton(
                        onPressed: () {
                          // TODO : send OTP
                          ref.read(_otpSent.notifier).state = true;
                        },
                        child: const Text('Send Code'),
                      ),
                    ),
                    onChanged: (txt) =>
                        ref.read(emailProvider.notifier).state = txt,
                  );
                },
              ),
              const Divider(height: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DisableWidget(
                    disable: !ref.watch(_otpSent),
                    child: CustomTextField(
                      decoration: const InputDecoration(labelText: 'OTP'),
                      onChanged: (txt) => ref.read(_otp.notifier).state = txt,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: ref.watch(_otpSent)
                        ? () {
                            final email = ref.read(emailProvider);
                            final otp = ref.read(_otp);
                            AuthService.verifyOTP(email, otp).then((value) {
                              if (value) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              } else {
                                ref.read(_errorMessage.notifier).state =
                                    'Invalid OTP!!!';
                              }
                            });
                          }
                        : null,
                    child: const Text('Verify'),
                  ),
                ],
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
}
