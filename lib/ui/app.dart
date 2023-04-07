import 'package:card_generator/models/user.dart';
import 'package:card_generator/services/users_service.dart';
import 'package:card_generator/ui/auth/login_page.dart';
import 'package:card_generator/ui/custom_future_builder.dart';
import 'package:card_generator/ui/users/user_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_page.dart';

final authenticatedUser = StateProvider<User?>((ref) {
  UsersService.init();
  return null;
});

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Applied Sciences',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Consumer(
        builder: (context, ref, child) {
          return (ref.watch(authenticatedUser) == null)
              ? const LoginPage()
              : const HomePage();
        },
      ),
    );
  }
}
