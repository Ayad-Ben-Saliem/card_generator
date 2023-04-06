import 'package:card_generator/models/user.dart';
import 'package:card_generator/services/users_service.dart';
import 'package:card_generator/ui/auth/login_page.dart';
import 'package:card_generator/ui/custom_future_builder.dart';
import 'package:card_generator/ui/users/user_form.dart';
import 'package:card_generator/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_page.dart';

final authenticatedUser = StateProvider<User?>((ref) => null);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Applied Sciences',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Consumer(
        builder: (context, ref, child) {
          final currentUser = ref.watch(authenticatedUser);

          return CustomFutureBuilder(
            future: UsersService.countUsers(),
            builder: (context, snapshot) {
              if (snapshot.data == 0) {
                return UserForm(
                  popOnComplete: false,
                  canCancel: false,
                  onSave: (user) {
                    ref.read(authenticatedUser.notifier).state = user;
                  },
                );
              }

              return (currentUser == null)
                  ? const LoginPage()
                  : const HomePage();
            },
          );
        },
      ),
    );
  }
}
