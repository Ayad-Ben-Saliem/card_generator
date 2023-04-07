import 'package:card_generator/ui/app.dart';
import 'package:card_generator/ui/cards/cards_view.dart';
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
          drawer: ref.watch(authenticatedUser)?.superUser == true
              ? _drawer()
              : null,
          body: const ImportCards(),
        );
      },
    );
  }

  Widget _drawer() {
    return Drawer(
      child: Builder(builder: (context) {
        return Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      return ListTile(
                        title: Text(ref.watch(authenticatedUser)!.name),
                        // onTap: () {},
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Users'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const UsersPage()),
                      );
                      Scaffold.of(context).closeDrawer();
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}
