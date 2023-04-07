import 'package:card_generator/models/user.dart';
import 'package:card_generator/services/users_service.dart';
import 'package:card_generator/storage/db.dart';
import 'package:card_generator/ui/auth/login_page.dart';
import 'package:card_generator/ui/home_page.dart';
import 'package:card_generator/ui/license_page.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authenticatedUser = StateProvider<User?>((ref) {
  UsersService.init();
  return null;
});

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: getLicence(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Column(
              children: [
                Text('${snapshot.error}'),
                const Divider(),
                SingleChildScrollView(child: Text('${snapshot.stackTrace}')),
              ],
            );
          }
          if (snapshot.data == null) return const LicensePage();
          return const HomePage();
          return Consumer(
            builder: (context, ref, child) {
              return (ref.watch(authenticatedUser) == null)
                  ? const LoginPage()
                  : const HomePage();
            },
          );
        },
      ),
    );
  }
}
