import 'package:card_generator/models/user.dart';
import 'package:card_generator/services/users_service.dart';
import 'package:card_generator/static.dart';
import 'package:card_generator/ui/custom-text-field.dart';
import 'package:card_generator/ui/disable-widget.dart';
import 'package:card_generator/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final name = StateProvider((ref) => '');
final email = StateProvider((ref) => '');
final password = StateProvider((ref) => '');
final confirmPassword = StateProvider((ref) => '');

final nameMessage = StateProvider<String?>((ref) {
  return ref.watch(name).isEmpty ? 'Name Required!!!' : null;
});

final emailMessage = StateProvider<String?>((ref) {
  final emailValue = ref.watch(email);
  return emailValue.isEmpty
      ? 'Email Required!!!'
      : emailValue.isValidEmail()
          ? null
          : 'Email Invalid!!!';
});

final passwordMessage = StateProvider<String?>((ref) {
  return ref.watch(email).isEmpty ? 'Password Required!!!' : null;
});

final mismatchPassword = StateProvider<String?>((ref) {
  return ref.watch(password) != ref.watch(confirmPassword)
      ? 'Passwords Mismatch!!!'
      : null;
});

final obscurePasswords = StateProvider((ref) => false);

class UserForm extends ConsumerWidget {
  final User? user;
  final bool changePassword;
  final void Function(User)? onSave;
  final bool popOnComplete;
  final bool canCancel;

  const UserForm({
    Key? key,
    this.user,
    this.changePassword = false,
    this.onSave,
    this.popOnComplete = true,
    this.canCancel = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        ref.read(name.notifier).state = user!.name;
        ref.read(email.notifier).state = user!.email;
        ref.read(password.notifier).state = user!.password;
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(user == null ? 'Add User' : 'Edit User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 512),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Consumer(
                          builder: (context, ref, child) {
                            return DisableWidget(
                              disable: changePassword,
                              child: CustomTextField(
                                text: user?.name,
                                decoration: const InputDecoration(labelText: 'Name'),
                                onChanged: (txt) => ref.read(name.notifier).state = txt,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Consumer(
                          builder: (context, ref, child) {
                            return Text(
                              ref.watch(nameMessage) ?? '',
                              style: errorTextStyle(context),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Consumer(
                          builder: (context, ref, child) {
                            return DisableWidget(
                              disable: changePassword,
                              child: CustomTextField(
                                text: user?.email,
                                decoration: const InputDecoration(labelText: 'Email'),
                                onChanged: (txt) =>
                                    ref.read(email.notifier).state = txt,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 8),
                        Consumer(
                          builder: (context, ref, child) {
                            return Text(
                              ref.watch(emailMessage) ?? '',
                              style: errorTextStyle(context),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        if (user == null || changePassword)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          obscureText: ref.watch(obscurePasswords),
                                          passwordField: true,
                                          onObscureTextChanged: (obscure) {
                                            ref.read(obscurePasswords.notifier).state =
                                                obscure;
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Password',
                                          ),
                                          onChanged: (txt) =>
                                              ref.read(password.notifier).state = txt,
                                        ),
                                        const SizedBox(width: 8),
                                        Consumer(
                                          builder: (context, ref, child) {
                                            return Text(
                                              ref.watch(nameMessage) ?? '',
                                              style: errorTextStyle(context),
                                            );
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, child) {
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          obscureText: ref.watch(obscurePasswords),
                                          passwordField: true,
                                          onObscureTextChanged: (obscure) {
                                            ref.read(obscurePasswords.notifier).state =
                                                obscure;
                                          },
                                          decoration: const InputDecoration(
                                            labelText: 'Confirm Password',
                                          ),
                                          onChanged: (txt) {
                                            ref.read(confirmPassword.notifier).state =
                                                txt;
                                          },
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          ref.watch(mismatchPassword) ?? '',
                                          style: errorTextStyle(context),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Divider(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canCancel)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () =>
                          popOnComplete ? Navigator.pop(context) : null,
                      child: const Text('Cancel'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return ElevatedButton(
                        onPressed: () {
                          try {
                            save(ref).then((user) {
                              if (user != null) onSave?.call(user);
                              if (popOnComplete) Navigator.pop(context, user);
                            });
                          } catch (error, stackTrace) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxHeight: 100),
                                  child: Column(
                                    children: [
                                      Text('$error'),
                                      const SizedBox(height: 16),
                                      Expanded(
                                        child: ListView(
                                          children: [Text('$stackTrace')],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Save'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<User?> save(WidgetRef ref) async {
    final user = User(
      id: this.user?.id,
      name: ref.read(name),
      email: ref.read(email),
      password: ref.read(password),
    );
    if (this.user == null) {
      return UsersService.saveUser(user);
    } else {
      if (changePassword) {
        return UsersService.changePassword(user.id!, user.password);
      } else {
        return UsersService.editUser(user);
      }
    }
  }
}
