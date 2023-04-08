import 'package:card_generator/ui/app.dart';
import 'package:card_generator/ui/auth/login_page.dart';
import 'package:card_generator/ui/cards/import_cards.dart';
import 'package:card_generator/ui/users/users_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Home Page')),
          drawer: _drawer(),
          body: const ImportCards(),
        );
      },
    );
  }

  Widget _drawer() {
    return Drawer(
      child: Builder(
        builder: (context) {
          return Column(
            children: [
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final currentUser = ref.watch(authenticatedUser);
                    return ListView(
                      children: [
                        if (currentUser == null)
                          ListTile(
                            title: const Text('Login'),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            ),
                          ),
                        if (currentUser != null)
                          ListTile(title: Text(currentUser.name)),
                        if (currentUser != null)
                          ListTile(
                            title: const Text('Logout'),
                            onTap: () => ref
                                .read(authenticatedUser.notifier)
                                .state = null,
                          ),
                        if (currentUser != null) const Divider(),
                        if (currentUser != null && currentUser.superUser)
                          ListTile(
                            title: const Text('Users'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UsersPage(),
                                ),
                              );
                              Scaffold.of(context).closeDrawer();
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
