import 'package:card_generator/models/license.dart';
import 'package:card_generator/storage/db.dart';
import 'package:card_generator/ui/custom-text-field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:date_field/date_field.dart';

final license = StateProvider((ref) => const License(name: ''));

class LicensePage extends StatelessWidget {
  const LicensePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              return Column(
                children: [
                  _nameField(ref),
                  _maxCardNumberField(ref),
                  _valueUntilField(ref),
                ],
              );
            },
          ),
        ),
        Row(
          children: [
            Consumer(
              builder: (context, ref, child) {
                return ElevatedButton(
                  onPressed: () {
                    setLicence(ref.read(license))
                        .then((_) => Navigator.pop(context));
                  },
                  child: const Text('Enter'),
                );
              },
            )
          ],
        ),
      ],
    );
  }

  Widget _nameField(WidgetRef ref) {
    return CustomTextField(
      text: ref.watch(license.select((license) => license.name)),
      onChanged: (txt) {
        ref.read(license.notifier).state =
            ref.read(license).copyWith(name: txt);
      },
    );
  }

  Widget _maxCardNumberField(WidgetRef ref) {
    return CustomTextField(
      text: ref
          .watch(
            license.select((license) => license.maxCardNumber),
          )
          .toString(),
      onChanged: (txt) {
        ref.read(license.notifier).state =
            ref.read(license).copyWith(maxCardNumber: int.tryParse(txt));
      },
      decoration: _clearDecoration(
        () => ref.read(license.notifier).state =
            ref.read(license).copyWith(validUntil: null),
      ),
    );
  }

  Widget _valueUntilField(WidgetRef ref) {
    return DateTimeField(
      mode: DateTimeFieldPickerMode.date,
      firstDate: DateTime.now(),
      selectedDate: ref.watch(
        license.select((license) => license.validUntil),
      ),
      onDateSelected: (date) {
        ref.read(license.notifier).state =
            ref.read(license).copyWith(validUntil: date);
      },
      decoration: _clearDecoration(
        () => ref.read(license.notifier).state =
            ref.read(license).copyWith(validUntil: null),
      ),
    );
  }

  InputDecoration _clearDecoration(VoidCallback onPressed) {
    return InputDecoration(
      suffixIcon: IconButton(
        onPressed: onPressed,
        icon: const Icon(Icons.clear),
      ),
    );
  }
}
