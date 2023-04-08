import 'package:card_generator/models/license.dart';
import 'package:card_generator/storage/db.dart';
import 'package:card_generator/ui/app.dart';
import 'package:card_generator/ui/custom-text-field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:date_field/date_field.dart';

final license = StateProvider((ref) => const License(name: ''));

class LicensePage extends StatelessWidget {
  const LicensePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('License Page')),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 256),
                  child: Consumer(
                    builder: (context, ref, child) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _nameField(ref),
                          _maxCardsNumberField(ref),
                          _valueUntilField(ref),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 0),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Consumer(
                  builder: (context, ref, child) {
                    return ElevatedButton(
                      onPressed: ref.watch(license).name.trim().isNotEmpty
                          ? () => setLicence(ref.read(license))
                              .then((_) => restartApp(ref))
                          : null,
                      child: const Text('Enter'),
                    );
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _nameField(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomTextField(
        text: ref.watch(license.select((license) => license.name)),
        onChanged: (txt) {
          ref.read(license.notifier).state =
              ref.read(license).copyWith(name: txt);
        },
        decoration: const InputDecoration(labelText: 'Name'),
      ),
    );
  }

  Widget _maxCardsNumberField(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomTextField(
        text: (ref.watch(license).maxCardsNumber ?? '').toString(),
        onChanged: (txt) {
          ref.read(license.notifier).state =
              ref.read(license).copyWith(maxCardsNumber: int.tryParse(txt));
        },
        decoration: _clearDecoration(
          () => ref.read(license.notifier).state =
              ref.read(license).copyWith(maxCardsNumber: null),
        ).copyWith(labelText: 'Max Cards Number'),
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r"^\d*")),
        ],
      ),
    );
  }

  Widget _valueUntilField(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DateTimeField(
        mode: DateTimeFieldPickerMode.date,
        firstDate: DateTime.now(),
        selectedDate: ref.watch(
          license.select((license) => license.expirationDate),
        ),
        onDateSelected: (date) {
          ref.read(license.notifier).state =
              ref.read(license).copyWith(expirationDate: date);
        },
        decoration: _clearDecoration(
          () => ref.read(license.notifier).state =
              ref.read(license).copyWith(expirationDate: null),
        ).copyWith(
          border: const OutlineInputBorder(),
          labelText: 'Expiration Date',
        ),
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
