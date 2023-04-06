import 'package:card_generator/services/users_service.dart';
import 'package:card_generator/ui/app.dart';
import 'package:card_generator/ui/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:card_generator/models/user.dart';
import 'package:card_generator/ui/users/user_form.dart';

final users = StreamProvider((ref) => UsersService.users());

class UsersPage extends StatelessWidget {
  const UsersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Users Page')),
      body: Column(
        children: [
          _buttons(),
          const Divider(height: 0),
          Expanded(child: _usersList()),
        ],
      ),
    );
  }

  Widget _buttons() {
    return Builder(builder: (context) {
      return Row(
        children: [
          _button(
            onPressed: () => _addEditUserDialog(context),
            child: Column(
              children: const [
                Icon(Icons.add),
                Text('Add User'),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _button({required VoidCallback? onPressed, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: TextButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }

  Widget _usersList() {
    return Consumer(
      builder: (context, ref, child) {
        return ref.watch(users).when(
              loading: () => const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(),
              ),
              data: (users) {
                return ListView.separated(
                  itemCount: users.length,
                  itemBuilder: (_, index) {
                    if (users[index] == null) return const Text('User is null');
                    return _userTile(users[index]!);
                  },
                  separatorBuilder: (_, index) => const Divider(
                    height: 0,
                    thickness: 0.5,
                  ),
                );
              },
              error: (error, stackTrace) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('$error'),
                    ),
                    const Divider(),
                    ListView(
                      shrinkWrap: true,
                      children: [Text('$stackTrace')],
                    ),
                  ],
                );
              },
            );
      },
    );
  }

  Widget _userTile(User user) {
    final disabled = user.enabled
        ? null
        : const TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          );
    return Builder(builder: (context) {
      return InkWell(
        onDoubleTap: () => _addEditUserDialog(context, user: user),
        child: ListTile(
          title: Text(user.name, style: disabled),
          subtitle: Text(user.email, style: disabled),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (user.enabled)
                IconButton(
                  onPressed: () => _addEditUserDialog(context, user: user),
                  icon: const Icon(Icons.edit_outlined),
                ),
              if (user.enabled)
                IconButton(
                  onPressed: () => _addEditUserDialog(
                    context,
                    user: user,
                    changePassword: true,
                  ),
                  icon: const Icon(Icons.vpn_key_off_outlined),
                ),
              Consumer(
                builder: (context, ref, child) {
                  if (user != ref.watch(authenticatedUser)) {
                    return IconButton(
                      onPressed: () {
                        UsersService.editUser(
                          user.copyWith(enabled: !user.enabled),
                        );
                      },
                      icon: const Icon(Icons.person_off_outlined),
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
        ),
      );
    });
  }

  void _addEditUserDialog(
    BuildContext context, {
    User? user,
    bool changePassword = false,
  }) {
    if (user != null && user.enabled == false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User Disabled')),
      );
      return;
    }
    ;
    showDialog(
      context: context,
      builder: (_) {
        return CustomDialog(
          child: UserForm(user: user, changePassword: changePassword),
        );
      },
    ).then((user) {});
  }
}
