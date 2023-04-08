import 'package:card_generator/models/user.dart';
import 'package:card_generator/services/users_service.dart';
import 'package:card_generator/storage/db.dart';
import 'package:card_generator/ui/error_page.dart';
import 'package:card_generator/ui/home_page.dart';
import 'package:card_generator/ui/license_page.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authenticatedUser = StateProvider<User?>((ref) {
  UsersService.init();
  return null;
});

final restartAppKey = StateProvider((ref) => 0);

void restartApp(WidgetRef ref) {
  ref.read(restartAppKey.notifier).state++;
}

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(context, ref) {
    ref.watch(restartAppKey);
    ref.watch(authenticatedUser);

    return MaterialApp(
      title: 'Cards Generator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: FutureBuilder(
        future: getLicence(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return ErrorPage(
              error: snapshot.error!,
              stackTrace: snapshot.stackTrace,
            );
          }
          if (snapshot.data == null) return const LicensePage();
          return const HomePage();
        },
      ),
    );
  }
}
